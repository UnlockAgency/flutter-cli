class Updater
    def self.check
        # puts colored :blue, "[:] Checking for a newer version"

        response = JSON.load(URI.open('https://api.github.com/repos/UnlockAgency/flutter-cli/releases/latest'))
        releaseName = (response['name'] || '0.1.0').tr('^0-9.', '')

        # Compare versions 
        if Gem::Version.new(Flttr::VERSION) < Gem::Version.new(releaseName)
            puts colored :yellow, "---------------------------------------------------------"
            puts colored :yellow, "| FLTTR Upgrade available                               |"
            puts colored :yellow, "---------------------------------------------------------"
            puts colored :yellow, " A new version is available for download: #{releaseName}"
            puts colored :yellow, " Run flttr upgrade to install it\n"
        end

        return Gem::Version.new(Flttr::VERSION) >= Gem::Version.new(releaseName)
    end

    def self.update
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

        puts colored :green, "\n[:] Done! Your current version:"
        system("flttr --version")
    end    
end