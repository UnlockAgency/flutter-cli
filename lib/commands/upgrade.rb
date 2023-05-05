require 'net/http'

module Commands
    class Upgrade
        def initialize(args)
            # 
        end

        def execute
            # https://github.com/UnlockAgency/flutter-cli/raw/master/releases/flttr-0.0.1.gem

            Net::HTTP.start("github.com") do |http|
                resp = http.get("/UnlockAgency/flutter-cli/raw/master/releases/flttr-latest.gem")
                open("flttr-latest.gem", "wb") do |file|
                    file.write(resp.body)
                end
            end
        end
    end
end
