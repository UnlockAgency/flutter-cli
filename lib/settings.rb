class Settings
    @@config = nil

    def self.refresh
        unless File.exist? '.config.yaml'
            FileUtils.touch('.config.yaml')
        end

        @@config = YAML.load_file('.config.yaml') || {}
    end

    def self.load
        unless @@config != nil
            refresh
        end
    end

    def self.get(key, default=nil)
        load

        return @@config[key] || default
    end

    def self.write(key, value)
        refresh

        @@config[key] = value
        
        File.write('.config.yaml', @@config.to_yaml)
    end

    def self.update(hash)
        raise TypeError, 'parameter has to be a hash' unless hash.is_a?(Hash)

        refresh
        
        @@config = @@config.merge(hash)

        File.write('.config.yaml', @@config.to_yaml)
    end

    def self.all
        load

        return @@config
    end
end