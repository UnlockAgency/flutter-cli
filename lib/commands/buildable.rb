require 'json'
require 'pp'
require 'yaml'
require 'fileutils'

module Commands
    class Buildable   
        attr_accessor :verbose, :platform, :flavor, :release    

        def initialize(args)
            @verbose = args[:verbose]
            @platform = args[:platform]
            @flavor = args[:flavor]
            @release = args[:release]
        end

        def execute
            # Check if the directory contains a pubspec.yaml file, which is required for a Flutter project.
            unless File.exist? "pubspec.yaml"
                warn colored :red, " [!] The directory doesn't contain a pubspec.yaml, make sure to run this command inside a Flutter project. " 
                exit
            end

            prepare_dir

            copy_configuration_files

            buildConfig = write_build_config

            if @platform == "ios"
                update_xcconfig(buildConfig)
            end
        end

        def prepare_dir
            # Creating config directory if it doesn't exist
            Dir.mkdir "config" unless File.exist? "config"
        end

        def copy_configuration_files
            begin
                configuration = YAML.load_file('config/.config.yaml')
            rescue
                configuration = {}
            end

            puts colored :blue, "\n[:] Copying configuration files"

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
                buildConfig = JSON.load(File.open("config/#{@flavor}.json"))
            rescue
                buildConfig = {}
            end

            platformConfigFileName = "config/#{@platform}/#{@flavor}.json"

            begin
                # Open signing configuration
                platformConfigAll = JSON.load(File.open(platformConfigFileName))
            rescue
                warn colored :red, "\n[!] File #{platformConfigFileName} does not exist, falling back to default {}\n\n"
                platformConfigAll = {}
            end

            if @platform == "ios"
                platformConfig = platformConfigAll["default"] || {}
                platformConfig = platformConfig.merge(@release ? platformConfigAll["release"] || {} : platformConfigAll["debug"] || {})

                if :verbose
                    puts colored :blue, "\n[:] Loaded platform config, combining it to the default config"
                    pp platformConfig
                end
                
                buildConfig = buildConfig.merge(platformConfig)
            else
                if @verbose
                    puts colored :blue, "\n[:] Loaded platform config, combining it to the default config"
                    pp platformConfigAll
                end

                buildConfig = buildConfig.merge(platformConfigAll)
            end

            File.open('./config/.build.json', 'w') do |file|
                file.write(JSON.dump(buildConfig))
            end

            return buildConfig
        end

        def update_xcconfig(buildConfig)
            # Before running the build, we are updating values inside Generated.xcconfig.
            # Flutter is also doing this later when running the build script, but some values are then representing the old ones.
            # We need specific values to be updated before starting flutters own build script.
            xcconfigFileName = 'ios/Flutter/Generated.xcconfig'

            Dir.mkdir "ios/Flutter" unless File.exist? "ios/Flutter"

            generatedXcodeConfig = {}

            if File.exist?(xcconfigFileName)
                File.open(xcconfigFileName) do |file|
                    file.each do |line|
                        key, value = line.chomp.split("=")
                        generatedXcodeConfig[key] = value
                    end
                end
            end

            # Now overwrite the existing keys with our noewly created buildConfig
            for key in buildConfig.keys
                generatedXcodeConfig[key] = buildConfig[key]
            end

            if :verbose
                puts colored :blue, "\n[:] Writing to Generated.xcconfig"
            end

            # Now print all lines back into Generated.xcconfig
            File.open(xcconfigFileName, "w") do |file|
                for key in generatedXcodeConfig.keys
                    line = "#{key}#{key.start_with?("//") ? "" : "=#{generatedXcodeConfig[key]}"}"

                    if :verbose
                        puts " - Writing into Generated.xcconfig: #{line}"
                    end

                    file.write "#{line}\n"
                end
            end
        end
    end
end