require 'open-uri'
require 'json'
require 'yaml'

module Commands
    class Init
        def initialize(args)
        end

        def execute
            puts colored :blue, "#{CHAR_FLAG} Initializing this directory.."

            # Make the config dir
            puts colored :default, "\n#{CHAR_VERBOSE} Creating the config/ios and config/android dirs if they don't yet exist" unless !$verbose
            Dir.mkdir "config" unless File.exist? "config"
            Dir.mkdir "config/android" unless File.exist? "config/android"
            Dir.mkdir "config/ios" unless File.exist? "config/ios"

            puts colored :blue, "\n#{CHAR_FLAG} Copying configuration files" unless !$verbose
            FileUtils.copy_entry File.join(File.dirname(__FILE__), '../../templates/config'), "config"

            puts colored :green, "#{CHAR_CHECK} Done!"
        end
    end
end
