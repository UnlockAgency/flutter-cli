require 'openssl'
require 'jwt'  
require 'net/http'

class Updater
    def self.check(silently=false)
        begin
            response = JSON.load(
                URI.open(
                    'https://api.github.com/repos/UnlockAgency/flutter-cli/releases/latest',
                    'Authorization' => "Bearer #{getAccessToken}"
                )
            )

            releaseName = (response['name'] || '0.1.0').tr('^0-9.', '')
        rescue
            # Request failed, we fake an up to date installation
            return true
        end

        # Compare versions 
        if !silently && Gem::Version.new(Flttr::VERSION) < Gem::Version.new(releaseName)
            puts colored :yellow, "---------------------------------------------------------"
            puts colored :yellow, "| FLTTR Upgrade available                               |"
            puts colored :yellow, "---------------------------------------------------------"
            puts colored :yellow, " A new version is available for download: #{releaseName}"
            puts colored :yellow, " Run flttr upgrade to install it\n"
        end

        return Gem::Version.new(Flttr::VERSION) >= Gem::Version.new(releaseName)
    end

    def self.update
        response = JSON.load(
            URI.open(
                'https://api.github.com/repos/UnlockAgency/flutter-cli/releases/latest',
                'Authorization' => "Bearer #{createJwt}"
            )
        )

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

    def self.getAccessToken
        accessToken = Settings.get('installation_access_token')
        accessTokenExpirationTime = Settings.get('installation_access_token_expiration_time')

        if accessToken == nil || accessTokenExpirationTime == nil 
            # Create a new access token
            return createAccessToken
        end

        # Check if the access token has expired, against now - 1 minute
        unless accessTokenExpirationTime < Time.now.to_i - 60
            return accessToken
        end

        return createAccessToken
    end
    
    def self.createJwt
        filePath = File.join(File.dirname(__FILE__), '../keys/2023-05-24.github.pem')
        private_pem = File.read(filePath)
        private_key = OpenSSL::PKey::RSA.new(private_pem)

        payload = {
            # issued at time, 60 seconds in the past to allow for clock drift
            iat: Time.now.to_i - 60,
            # JWT expiration time (10 minute maximum)
            exp: Time.now.to_i + (10 * 60),
            # GitHub App's identifier
            iss: '338415'
        }

        JWT.encode(payload, private_key, "RS256")
    end

    def self.createAccessToken
        jwtToken = createJwt

        # Get the installation ID of the app
        response = JSON.load(
            URI.open(
                'https://api.github.com/repos/UnlockAgency/flutter-cli/installation',
                'Authorization' => "Bearer #{jwtToken}"
            )
        )

        installationId = response['id']

        # Request an access token
        uri = URI.parse("https://api.github.com/app/installations/#{installationId}/access_tokens")
        headers = {
            'Authorization': "Bearer #{jwtToken}",
        }

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri, headers)
        
        response = http.request(request)

        responseBody = JSON.load(response.body)
        accessToken = responseBody['token']
        expirationTime = Time.parse(responseBody['expires_at'])

        Settings.update({
            'installation_access_token' => accessToken,
            'installation_access_token_expiration_time' => expirationTime.to_i,
        })

        return accessToken
    end
end