require 'open-uri'
require 'json'

module Commands
    class Upgrade
        def initialize(args)
            # 
        end

        def execute
            # Try to find the latest release on Github
            puts colored :blue, "[:] Looking for the latest release.."

            response = JSON.load(URI.open('https://api.github.com/repos/UnlockAgency/flutter-cli/releases/latest'))
            downloadUrl = response['assets']&.select { |a| a['browser_download_url'].end_with?('.gem') }&.map { |a| a['browser_download_url'] }&.first

            unless downloadUrl
                warn colored :red, "\n[!] Unable to locate download url from response"
                return
            end

            puts " - Found: #{downloadUrl}"

            puts colored :blue, "\n[:] Downloading.."

            filename = 'flttr-latest.gem'
            open(filename, 'wb') do |file|
                file << URI.open(downloadUrl).read
            end

            puts colored :blue, "\n[:] Finished download, installing.."
            puts " - gem install flttr-latest.gem"

            system("gem install '#{filename}'")

            # Remove the downloaded file again
            puts colored :blue, "\n[:] Deleting #{filename}"
            File.delete(filename) if File.exist?(filename)

            puts colored :green, "\n[:] Done! You're current version:"
            system("flttr --version")
        end
    end
end
