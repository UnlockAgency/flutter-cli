
module Commands
    class Init
        def initialize(args)
        end

        def execute
            puts colored :blue, "#{CHAR_FLAG} Initializing this directory.."

            initializer = Initializer.new(Dir.pwd)
            initializer.run()
            initializer.set_flavors(['test', 'accept', 'production', 'release'])

            puts colored :green, "#{CHAR_CHECK} Done!"
        end
    end
end
