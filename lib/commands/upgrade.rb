require 'open-uri'
require 'json'

module Commands
    class Upgrade
        def initialize(args)
            # 
        end

        def execute
            # Try to find the latest release on Github
            upToDate = Updater.check(true)

            if upToDate
                puts colored :green, 'You are already up to date!'
                return
            end

            Updater.update
        end
    end
end
