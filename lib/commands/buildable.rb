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
            # Check if the directory contains a pubspec.yaml file, which is required for a Flutter project.
            unless File.exist? "pubspec.yaml"
                warn colored :red, "#{CHAR_ERROR} The directory doesn't contain a pubspec.yaml, make sure to run this command inside a Flutter project. " 
                # exit
            end

            prepare_dir

            copy_configuration_files

            buildConfig = write_build_config

            if @platform == "ios"
                update_xcconfig(buildConfig)
            end
        end

        def prepare_dir
            puts colored :default, "\n#{CHAR_VERBOSE} Checking for existence of config/ dir" unless !$verbose

            # Creating config directory if it doesn't exist
            Dir.mkdir "config" unless File.exist? "config"
        end

        def copy_configuration_files
            begin
                puts colored :default, "\n#{CHAR_VERBOSE} Loading config/.config.yaml contents" unless !$verbose
                configuration = YAML.load_file('config/.config.yaml')
            rescue
                warn colored :yellow, "\n#{CHAR_WARNING} File config/config.yaml doesn\'t exist, using empty configuration: {}"
                configuration = {}
            end

            puts colored :blue, "\n#{CHAR_CHECK} Copying configuration files"

            if configuration.key?('files')
                filesToCopy = configuration['files']

                for key in filesToCopy.keys
                    fileToCopy = filesToCopy[key]

                    if fileToCopy.key?(:flavor)
                        puts " - Copying #{fileToCopy[@flavor]} to #{key}"
                        FileUtils.cp(fileToCopy[@flavor], key)
                    end
                end
            end
        end

        def write_build_config
            begin
                # Build a .build.json file
                puts colored :default, "\n#{CHAR_VERBOSE} Loading config/#{@flavor}.json" unless !$verbose
                buildConfig = JSON.load(File.open("config/#{@flavor}.json"))
            rescue
                warn colored :yellow, "\n#{CHAR_WARNING} File config/#{@flavor}.json doesn't exit, using empty configuration: {}" 
                buildConfig = {}
            end

            platformConfigFileName = "config/#{@platform}/#{@flavor}.json"

            begin
                # Open signing configuration
                puts colored :default, "\n#{CHAR_VERBOSE} Loading #{platformConfigFileName}" unless !$verbose
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

            puts colored :default, "\n#{CHAR_VERBOSE} Loading the values from #{xcconfigFileName}" unless !$verbose

            if File.exist?(xcconfigFileName)
                File.open(xcconfigFileName) do |file|
                    file.each do |line|
                        key, value = line.chomp.split("=")
                        generatedXcodeConfig[key] = value
                    end
                end
            end

            puts colored :default, "\n#{CHAR_VERBOSE} Overriding the values in Generated.xcconfig to the build configuration" unless !$verbose

            # Now overwrite the existing keys with our noewly created buildConfig
            for key in buildConfig.keys
                generatedXcodeConfig[key] = buildConfig[key]
            end

            puts colored :blue, "\n#{CHAR_FLAG} Writing to Generated.xcconfig" unless !$verbose±

            # Now print all lines back into Generated.xcconfig
            File.open(xcconfigFileName, "w") do |file|
                for key in generatedXcodeConfig.keys
                    line = "#{key}#{key.start_with?("//") ? "" : "=#{generatedXcodeConfig[key]}"}"

                    puts colored :default, "\n#{CHAR_VERBOSE} Writing into Generated.xcconfig: #{line}" unless !$verbose

                    file.write "#{line}\n"
                end
            end
        end
    end
end