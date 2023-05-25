module Commands
    class Run < Commands::Buildable

        def initialize(args)
            super 
        end

        def execute
            super 

            command = "flutter run #{@platform} --target=lib/main.dart --dart-define-from-file=config/.build.json"
            command += @release ? " --release" : ""

            puts colored :blue, "\n#{CHAR_CHECK} Running app in flavor: #{@flavor}"
            puts colored :default, "#{command}\n\n"

            exec(command)
        end
    end
end