module Commands
    class Build < Commands::Buildable

        def initialize(args)
            super 

            @@artifact = args[:artifact]
            @@obfuscation = args['no-obfuscation'] == false
            @@prepare = args['prepare'] == true
        end

        def execute
            super 

            if @@prepare
                puts colored :blue, "\n#{CHAR_FLAG} Skipping actual build in prepare mode"
                return
            end

            artifactType = @@artifact || "apk"
            mode = "build #{@platform == "ios" ? "ios" : artifactType}"

            command = "flutter #{mode} --target=lib/main.dart --dart-define-from-file=config/.build.json"
            command += @@obfuscation ? " --obfuscate --split-debug-info=./debug_info" : ""
            command += @release ? " --release #{@platform == "ios" ? "--no-codesign" : ""}" : ""

            puts colored :blue, "\n#{CHAR_FLAG} Building app for flavor: #{@flavor}"
            puts colored :default, "#{command}\n\n"

            exec(command)
        end
    end
end