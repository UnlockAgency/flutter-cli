require 'open-uri'
require 'json'
require 'yaml'

module Commands
    class Config
        attr_accessor :version_check    

        def initialize(args)
            @version_check = args['version-check']
        end

        def execute
            puts colored :blue, "[:] Updating your configuration preferences.."

            config = Settings.all

            if @version_check != nil
                puts " - Updating version-check to #{version_check == 'true'}"
                config['version_check'] = version_check == 'true'
            end

            Settings.update(config)
        end
    end
end
