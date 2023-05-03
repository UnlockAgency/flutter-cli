module Commands
    class Run < Commands::Base

        def initialize(args)
            super 
        end

        def execute
            super 

            command = "flutter run #{platform} --target=lib/main.dart --dart-define-from-file=config/.build.json"
            command += :release ? " --release" : ""

            puts "\n[:] Running app in flavor: #{flavor}"
            puts "[:] #{command}\n\n"

            exec(command)
        end
    end
end