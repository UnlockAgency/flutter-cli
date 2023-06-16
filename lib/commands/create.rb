require 'tty-prompt'

module Commands
    class Create
        attr_accessor :project_name, :project_name_lower_cased, :project_dir, :flavors, :bundle_identifier_ios, :bundle_identifier_android

        def initialize()
            @@prompt = TTY::Prompt.new
        end

        def execute
            create_new_project = @@prompt.yes?("Do you want to create a new project in this directory?") do |q|
                q.default false
            end

            if create_new_project
                @project_name = @@prompt.ask("What's the project name?", required: true)
            else
                inside_new_project_dir = @@prompt.yes?("Are you currently inside a Flutter project directory?")
                unless inside_new_project_dir
                    warn colored :red, "#{CHAR_ERROR} You must be inside a Flutter project directory"
                    exit
                end

                @project_name = File.basename(Dir.getwd)
                @project_dir = Dir.pwd
            end

            @project_name = @project_name
            @project_name_lower_cased = @project_name.downcase

            if create_new_project
                puts colored :blue, "#{CHAR_FLAG} Running installation script"
                system("flutter create #{@project_name_lower_cased}")

                @project_dir = "#{Dir.pwd}/#{@project_name_lower_cased}"
            end

            initialize_directory

            puts colored :default, "#{CHAR_VERBOSE} Moved into #{@project_dir}" unless !$verbose

            @bundle_identifier_ios = @@prompt.ask("What's the iOS bundle identifier?", required: true) do |q|
                q.validate(/^([a-zA-Z.-]+)$/)
            end

            @bundle_identifier_android = @@prompt.ask("What's the Android package name?", required: true) do |q|
                q.validate(/^([a-zA-Z._]+)$/)
            end

            puts colored :default, "#{CHAR_VERBOSE} Set bundle id for iOS: #{@bundle_identifier_ios} and Android: #{@bundle_identifier_android}" unless !$verbose

            install_dependencies

            update_pubspec_file

            # Check if the user has configured a boilerplate repository
            if Settings.get('boilerplate_repository').nil?
                puts colored :default, "#{CHAR_VERBOSE} No boilerplate repository has been configured yet" unless !$verbose
                setup_boilerplate_repository = @@prompt.yes?("Do you want to add a boilerplate repository?") do |q|
                    q.default false
                end

                if setup_boilerplate_repository
                    boilerplate_repository = @@prompt.ask("What's the location of boilerplate repository?", required: true)
                    Settings.write('boilerplate_repository', boilerplate_repository)
                end
            end

            unless Settings.get('boilerplate_repository').nil?
                copy_from_boilerplate
            end

            puts colored :blue, "#{CHAR_FLAG} Initializing l10n"
            system("cd #{@project_dir} && flutter gen-l10n")

            # Rename android package name
            fileRegex=".*\.(xml|gradle|kt)$"
            system("find -E #{@project_dir}/android -type f -regex '#{fileRegex}' -exec sed -i '' s/com.example.#{@project_name_lower_cased}/#{@bundle_identifier_android}/g {} \\; > /dev/null")

            # Create firebase projects if necessary
            setup_firebase = @@prompt.yes?("Do you want to link the Firebase project to the flavors?") do |q|
                q.default false
            end

            if setup_firebase
                link_firebase_projects
            end

            puts colored :green, "\n#{CHAR_CHECK} Done! Your project is ready"
        end

        def initialize_directory
            # Configure the flavors
            choices = %w(test accept production release)
            @flavors = @@prompt.multi_select('Choose the flavors you want to configure', choices, echo: false)

            initializer = Initializer.new(@project_dir)
            initializer.run()
            initializer.set_flavors(flavors)
        end

        def install_dependencies
            # Install dependencies
            puts colored :blue, "#{CHAR_FLAG} Adding dependencies"
            dependencies = [
                "go_router",
                "logger",
                "intl",
                "shared_preferences", 
                "dio", 
                "get_it", 
                "flutter_secure_storage", 
                "firebase_core", 
                "firebase_analytics", 
                "firebase_crashlytics", 
                "sentry_flutter", 
                "uuid", 
                "package_info_plus", 
                "--dev flutter_launcher_icons"
            ]

            for dependency in dependencies do
                puts colored :default, "#{CHAR_VERBOSE} flutter pub add #{dependency}" unless !$verbose
                system("cd #{@project_dir} && flutter pub add #{dependency}")
            end
        end

        def update_pubspec_file
            puts colored :blue, "#{CHAR_FLAG} Modifying pubspec.yaml file"

            # Modifiy pubspec.yaml
            pubspec = YAML.load(File.read("#{@project_dir}/pubspec.yaml"))
            pubspec['dev_dependencies']['flutter_localizations'] = {
                'sdk' => 'flutter'
            }

            pubspec['flutter']['generate'] = true

            File.write("#{@project_dir}/pubspec.yaml", pubspec.to_yaml)
        end

        def link_firebase_projects
            @flavors.each do |flavor|
                projectId = @@prompt.ask("What's the Firebase project identifier for #{flavor}?", required: true)
                system("cd #{@project_dir} && flutterfire config --project=#{projectId} --out=lib/firebase_options_#{flavor}.dart --ios-bundle-id=#{@bundle_identifier_ios}.#{flavor} --android-package-name=#{@bundle_identifier_android}.#{flavor}")
            end
        end

        def copy_from_boilerplate
            boilerplate_repository = Settings.get('boilerplate_repository')

            if boilerplate_repository.nil?
                warn colored :red, "#{CHAR_ERROR} You haven't configured a boilerplate repository"
                exit
            end

            boilerplate_dir = "#{@project_dir}/tmp"

            Dir.mkdir boilerplate_dir unless File.exist? boilerplate_dir

            # git@gitlab.e-sites.nl:team-i/flutter/boilerplate.git
            system("git archive --remote=#{boilerplate_repository} HEAD | tar -x -C #{boilerplate_dir}")

            fileRegex=".*\.(dart|md|xcconfig|plist)$"

            # Replace variables
            system("find -E #{boilerplate_dir} -type f -regex '#{fileRegex}' -exec sed -i '' s/_BUNDLE_IDENTIFIER_IOS_/#{@bundle_identifier_ios}/g {} \\; > /dev/null")
            system("find -E #{boilerplate_dir} -type f -regex '#{fileRegex}' -exec sed -i '' s/_PROJECT_NAME_LOWER_CASED_/#{@project_name_lower_cased}/g {} \\; > /dev/null")
            system("find -E #{boilerplate_dir} -type f -regex '#{fileRegex}' -exec sed -i '' s/_PROJECT_NAME_/#{@project_name}/g {} \\; > /dev/null")

            FileUtils.copy_entry boilerplate_dir, @project_dir

            # Remove /test and /templates
            FileUtils.remove_dir("#{@project_dir}/test")
            FileUtils.remove_dir("#{@project_dir}/templates")

            Dir.mkdir "#{@project_dir}/test" unless File.exist? "#{@project_dir}/test"

            FileUtils.remove_dir(boilerplate_dir)
        end
    end
end
