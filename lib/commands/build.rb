module Commands
    class Build < Commands::Buildable

        def initialize(args)
            super 

            # Android
            @@artifact = args[:artifact]

            # iOS
            @@archive = args[:archive] == true
            @@codesign = args[:codesign] == true
            @@exportMethod = args['export-method']

            @@obfuscation = args['obfuscation'] == true
            @@prepare = args['dry-run'] == true

            # Web
            @@renderer = args['web-renderer']
        end

        def execute
            super 

            if @platform == "android"
                command = build_android
            elsif @platform == "ios"
                command = build_ios
            else
                command = build_web
            end

            if @@prepare
                puts colored :blue, "\n#{CHAR_FLAG} Skipping actual build in dry-run mode"
                puts colored :default, "#{command}\n\n"
                return
            end

            puts colored :blue, "\n#{CHAR_FLAG} Building app for flavor: #{@flavor}"
            puts colored :default, "#{command}\n\n"

            exec(command)
        end

        def build_android
            artifactType = @@artifact || "apk"
            mode = "build #{artifactType}"

            command = "flutter #{mode} --target=lib/main.dart --dart-define-from-file=config/.build.json"
            command += @@obfuscation ? " --obfuscate --split-debug-info=./debug_info" : ""
            command += @release ? " --release" : ""

            return command
        end

        def build_ios
            exportOptionsPath = generate_ios_export_options

            buildMode = @@archive ? "ipa" : "ios"
            mode = "build #{buildMode}"

            command = "flutter #{mode} --target=lib/main.dart --dart-define-from-file=config/.build.json"
            command += @@obfuscation ? " --obfuscate --split-debug-info=./debug_info" : ""
            command += @release ? " --release #{@@codesign == false ? "--no-codesign" : ""}" : ""

            unless exportOptionsPath.nil? || exportOptionsPath.empty?
                command += " --export-options-plist=#{exportOptionsPath}"
            end

            return command
        end

        def build_web
            command = "flutter build web --target=lib/main.dart --dart-define-from-file=config/.build.json"

            unless @@renderer.nil?
                command += " --web-renderer #{@@renderer}"
            end

            return command
        end

        def generate_ios_export_options
            unless @@archive && @@exportMethod != nil
                return nil
            end

            puts colored :blue, "\n#{CHAR_FLAG} Writing the export_options to ios/export_options.plist"

            contents = File.read(File.join(File.dirname(__FILE__), '../../templates/build/ios/export_options.plist'))
            exportOptionsPlist = contents.gsub('{EXPORT_METHOD}', @@exportMethod)

            [
                'PRODUCT_BUNDLE_IDENTIFIER', 
                'PROVISIONING_PROFILE_SPECIFIER', 
                'CODE_SIGN_IDENTITY', 
                'DEVELOPMENT_TEAM'
            ].each do |key|
                if @buildConfig.fetch(key, '') == ''
                    warn colored :yellow, "\n#{CHAR_WARNING} You haven't provided a value for #{key} in your config/ios/#{@flavor}.json file"
                end

                exportOptionsPlist = exportOptionsPlist.gsub("{#{key}}", @buildConfig.fetch(key, ''))
            end

            begin
                # Write the export options to the projects ios folder
                File.open('./ios/export_options.plist', 'w') do |file|
                    file.write(exportOptionsPlist)
                end
            rescue => e
                warn colored :red, "\n#{CHAR_ERROR} Unable to write the ios/export_options.plist file: \n#{e.message}"
                exit
            end

            return './ios/export_options.plist'
        end
    end
end