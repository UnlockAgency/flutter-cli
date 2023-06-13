require 'json'
require 'pp'
require 'yaml'
require 'fileutils'

module Commands
    class Buildable   
        attr_accessor :platform, :flavor, :release    

        def initialize(args)
            @platform = args[:platform]
            @flavor = args[:flavor]
            @release = args[:release]
        end

        def execute
            
            prepare_dir

            copy_configuration_files

            buildConfig = write_build_config

            if @platform == "ios"
                # Update the signing certificate
                if buildConfig.key?('CODE_SIGN_IDENTITY')
                    update_ios_signing_certificate(buildConfig['CODE_SIGN_IDENTITY'])
                end

                update_xcconfig(buildConfig)
            end
        end

        def prepare_dir
            puts colored :default, "#{CHAR_VERBOSE} Checking for existence of config/ dir" unless !$verbose

            # Creating config directory if it doesn't exist
            Dir.mkdir "config" unless File.exist? "config"
        end

        def copy_configuration_files
            begin
                puts colored :default, "#{CHAR_VERBOSE} Loading config/.config.yaml contents" unless !$verbose
                configuration = YAML.load_file('config/.config.yaml')
            rescue
                warn colored :yellow, "\n#{CHAR_WARNING} File config/config.yaml doesn\'t exist, using empty configuration: {}"
                configuration = {"android" => {}, "ios" => {}}
            end

            unless configuration.key?(@platform)
                warn colored :red, <<-TEXT
#{CHAR_ERROR} File config/config.yaml doesn\'t support platform specific configuration
  You have to specify configuration per platform, like:

  "android":
    "files":
      "path/to/new_file"
        release: "path/to/copyable_file"
        
  "ios":
    "files":
      "path/to/new_file"
        release: "path/to/copyable_file"
TEXT
                exit
            end

            platformConfig = configuration[@platform]

            if platformConfig.key?('files')
                puts colored :blue, "\n#{CHAR_FLAG} Copying configuration files"
                numberOfCopiedFiles = 0
                filesToCopy = platformConfig['files']

                for key in filesToCopy.keys
                    fileToCopy = filesToCopy[key]

                    if fileToCopy.key?(@flavor)
                        puts colored :default, "Copying #{fileToCopy[@flavor]} to #{key}" 
                        FileUtils.cp(fileToCopy[@flavor], key)

                        numberOfCopiedFiles += 1
                    end
                end

                puts colored :green, "\n#{CHAR_CHECK} Copied #{numberOfCopiedFiles} file(s)"
            else
                puts colored :blue, "\n#{CHAR_FLAG} No configuration files to copy"
            end
        end

        def write_build_config
            begin
                # Build a .build.json file
                puts colored :default, "#{CHAR_VERBOSE} Loading config/#{@flavor}.json" unless !$verbose
                buildConfig = JSON.load(File.open("config/#{@flavor}.json"))
            rescue
                warn colored :yellow, "\n#{CHAR_WARNING} File config/#{@flavor}.json doesn't exit, using empty configuration: {}" 
                buildConfig = {}
            end

            platformConfigFileName = "config/#{@platform}/#{@flavor}.json"

            begin
                # Open signing configuration
                puts colored :default, "#{CHAR_VERBOSE} Loading #{platformConfigFileName}" unless !$verbose
                platformConfigAll = JSON.load(File.open(platformConfigFileName))
            rescue
                warn colored :yellow, "\n#{CHAR_WARNING} File #{platformConfigFileName} does not exist, using empty configuration: {}"
                platformConfigAll = {}
            end

            if @platform == "ios"
                platformConfig = platformConfigAll["default"] || {}
                platformConfig = platformConfig.merge(@release ? platformConfigAll["release"] || {} : platformConfigAll["debug"] || {})

                puts colored :green, "\n#{CHAR_CHECK} Loaded platform config, combining it to the default config"

                pp platformConfig unless !$verbose
                
                buildConfig = buildConfig.merge(platformConfig)
            else
                puts colored :green, "\n#{CHAR_CHECK} Loaded platform config, combining it to the default config"

                pp platformConfigAll unless !$verbose

                buildConfig = buildConfig.merge(platformConfigAll)
            end

            File.open('./config/.build.json', 'w') do |file|
                file.write(JSON.dump(buildConfig))
            end

            puts colored :green, "\n#{CHAR_CHECK} Wrote configuration to config/.build.json"
            pp buildConfig unless !$verbose

            return buildConfig
        end

        def update_xcconfig(buildConfig)
            # Before running the build, we are updating values inside Generated.xcconfig.
            # Flutter is also doing this later when running the build script, but some values are then representing the old ones.
            # We need specific values to be updated before starting flutters own build script.
            xcconfigFileName = 'ios/Flutter/Generated.xcconfig'

            unless File.exist? "ios"
                warn colored :yellow, "\n#{CHAR_WARNING} No iOS folder is present in the directory, make sure you're running the command from inside a projects root" 
                return
            end

            Dir.mkdir "ios/Flutter" unless File.exist? "ios/Flutter"

            generatedXcodeConfig = {}

            puts colored :default, "#{CHAR_VERBOSE} Loading the values from #{xcconfigFileName}" unless !$verbose

            if File.exist?(xcconfigFileName)
                File.open(xcconfigFileName) do |file|
                    file.each do |line|
                        key, value = line.chomp.split("=")
                        generatedXcodeConfig[key] = value
                    end
                end
            end

            puts colored :default, "#{CHAR_VERBOSE} Overriding the values in Generated.xcconfig to the build configuration" unless !$verbose

            # Now overwrite the existing keys with our noewly created buildConfig
            for key in buildConfig.keys
                generatedXcodeConfig[key] = buildConfig[key]
            end

            puts colored :blue, "\n#{CHAR_FLAG} Writing to Generated.xcconfig"

            # Now print all lines back into Generated.xcconfig
            File.open(xcconfigFileName, "w") do |file|
                for key in generatedXcodeConfig.keys
                    line = "#{key}#{key.start_with?("//") ? "" : "=#{generatedXcodeConfig[key]}"}"

                    puts colored :default, "#{CHAR_VERBOSE} Writing into Generated.xcconfig: #{line}" unless !$verbose

                    file.write "#{line}\n"
                end
            end
        end

        def update_ios_signing_certificate(newValue)
            fileLocation = "#{Dir.home}/.flutter_settings"

            puts colored :blue, "\n#{CHAR_FLAG} Updating code signing identity to: #{newValue}"

            begin
                # Open signing configuration
                puts colored :default, "#{CHAR_VERBOSE} Opening Flutter settings file at: #{fileLocation}" unless !$verbose
                flutterSettings = JSON.load(File.open(fileLocation))

                # Create a backup of the file if it doesn't exist
                unless File.exist?("#{fileLocation}.bak")
                    puts colored :default, "#{CHAR_VERBOSE} Creating backup file: #{fileLocation}.bak" unless !$verbose

                    File.open("#{fileLocation}.bak", 'w') do |file|
                        file.write(JSON.dump(flutterSettings))
                    end
                end
            rescue
                warn colored :yellow, "\n#{CHAR_WARNING} Flutter settings file at: #{fileLocation} does not exist, using empty configuration: {}"
                flutterSettings = {}
            end

            flutterSettings['ios-signing-cert'] = newValue

            File.open(fileLocation, 'w') do |file|
                file.write(JSON.dump(flutterSettings))
            end

            puts colored :green, "\n#{CHAR_CHECK} Updated flutter settings"
        end
    end
end