module Commands
    class Build < Commands::Base
        attr_accessor :artifact

        def initialize(args)
            super 

            @artifact = args[:artifact]
        end

        def execute
            super 

            artifactType = @artifact || "apk"
            mode = "build #{platform == "ios" ? "ios" : artifactType}"

            command = "flutter #{mode} --target=lib/main.dart --dart-define-from-file=config/.build.json"
            command += :release ? " --release #{platform == "ios" ? "--no-codesign" : ""}" : ""

            puts "\n[:] Running app in flavor: #{:flavor}"
            puts "[:] #{command}\n\n"

            exec(command)
        end
    end
end