require 'open-uri'

module Commands
    class Upgrade
        def initialize(args)
            # 
        end

        def execute
            filename = 'flttr-latest.gem'

            puts "[:] Downloading latest release from: https://github.com/UnlockAgency/flutter-cli/raw/master/releases/#{filename}"

            open(filename, 'wb') do |file|
                file << URI.open("https://github.com/UnlockAgency/flutter-cli/raw/master/releases/#{filename}").read
            end

            puts "\n[:] Finished download, installing.."
            puts " - gem install flttr-latest.gem"

            system("gem install '#{filename}'")

            # Remove the downloaded file again
            puts "\n[:] Deleting #{filename}"
            File.delete(filename) if File.exist?(filename)

            puts "\n[:] Done! You're current version:"
            system("flttr --version")
        end
    end
end
