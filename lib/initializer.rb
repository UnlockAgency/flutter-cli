require 'open-uri'
require 'yaml'

class Initializer
    attr_accessor :directory

    @@packageDirectory = "#{Dir.home}/.flttr"

    def initialize(directory)
        @directory = directory
    end

    def run
        # Make the config dir
        puts colored :default, "#{CHAR_VERBOSE} Creating the config/ios and config/android dirs if they don't yet exist" unless !$verbose
        Dir.mkdir "#{@directory}/config" unless File.exist? "#{@directory}/config"
        Dir.mkdir "#{@directory}/config/android" unless File.exist? "#{@directory}/config/android"
        Dir.mkdir "#{@directory}/config/ios" unless File.exist? "#{@directory}/config/ios"

        puts colored :blue, "\n#{CHAR_FLAG} Copying configuration files"
        FileUtils.copy_entry File.join(File.dirname(__FILE__), '../templates/project/config'), "#{@directory}/config"

        puts colored :blue, "\n#{CHAR_FLAG} Copying default .env"
        FileUtils.copy_entry File.join(File.dirname(__FILE__), '../templates/project/.env.dist'), "#{@directory}/.env"
    end

    def set_flavors(flavors)
        # Check if the file exists
        unless File.exist? "#{@directory}/config/.config.yaml"
            warn colored :red, "#{CHAR_ERROR} The /config/.config.yaml file doesn't exist"
            exit
        end

        # Update the config file with the configured flavors
        configFile = YAML.load(File.read("#{@directory}/config/.config.yaml"))
        configFile['flavors'] = flavors

        ['android', 'ios'].each do |platform|
            # Remove redundant flavor file settings if present
            if configFile.key?(platform) && configFile[platform].key?('files')
                configFile[platform]['files'].each do |key, value|
                    configFile[platform]['files'][key] = value.select { |k| flavors.include? k }
                end
            end
        end

        File.write("#{@directory}/config/.config.yaml", configFile.to_yaml)

        ['test', 'accept', 'production', 'release'].each do |filename|
            # Check if the flavor is enabled, otherwise delete the file
            unless flavors.include? filename 
                ["#{@directory}/config/#{filename}.json", "#{@directory}/config/android/#{filename}.json", "#{@directory}/config/ios/#{filename}.json"].each do |file|
                    File.delete(file) unless !File.exist? file
                end
            end
        end
    end
end