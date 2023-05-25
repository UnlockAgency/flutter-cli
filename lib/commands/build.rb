module Commands
    class Build < Commands::Buildable
        attr_accessor :artifact

        def initialize(args)
            super 

            @artifact = args[:artifact]
        end

        def execute
            super 

            artifactType = @artifact || "apk"
            mode = "build #{@platform == "ios" ? "ios" : artifactType}"

            command = "flutter #{mode} --target=lib/main.dart --dart-define-from-file=config/.build.json"
            command += @release ? " --release #{@platform == "ios" ? "--no-codesign" : ""}" : ""

            puts colored :blue, "\n#{CHAR_FLAG} Building app for flavor: #{@flavor}"
            puts colored :green, "#{command}\n\n"

            exec(command)
        end
    end
end