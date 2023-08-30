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
            @@prepare = args['prepare'] == true
        end

        def execute
            super 

            if @platform == "android"
                command = build_android
            else
                command = build_ios
            end

            if @@prepare
                puts colored :blue, "\n#{CHAR_FLAG} Skipping actual build in prepare mode"
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
            buildMode = @@archive ? "ipa" : "ios"
            mode = "build #{buildMode}"

            command = "flutter #{mode} --target=lib/main.dart --dart-define-from-file=config/.build.json"
            command += @@exportMethod != nil ? " --export-method #{@@exportMethod}" : ""
            command += @@obfuscation ? " --obfuscate --split-debug-info=./debug_info" : ""
            command += @release ? " --release #{@@codesign == false ? "--no-codesign" : ""}" : ""

            return command
        end
    end
end