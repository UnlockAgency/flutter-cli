require 'dotenv'

module Commands
    class TranslationsImport
        XCODE_RESOURCES_PATH = "ios/Runner/Resources"
        TRANSLATIONS_PATH = "lib/l10n"
        PRONTALIZE_HOST = "https://prontalize.nl"

        attr_accessor :directory, :prontalizeApiKey, :prontalizeProjectId    

        def initialize(args)
            Dotenv.load

            @directory = File.expand_path(File.dirname(__FILE__))

            @prontalizeApiKey = ENV['PRONTALIZE_API_KEY']
            @prontalizeProjectId = ENV['PRONTALIZE_PROJECT_ID']

            if @prontalizeApiKey.nil? || @prontalizeProjectId.nil?
                warn colored :red, "#{CHAR_ERROR} Missing PRONTALIZE_API_KEY and/or PRONTALIZE_PROJECT_ID. Set it in the .env file in the root of your project."
                exit
            end
        end

        def execute
    
            translations = getTranslations()

            if translations.empty?
                warn colored :red, "#{CHAR_ERROR} No translations"
                exit
            end

            files = parse(translations)

            write(files)

            puts colored :blue, "\n#{CHAR_FLAG} Running flutter gen-l10n"
            system("flutter gen-l10n")

            puts colored :green, "\n#{CHAR_CHECK} Finished!"
        end

        def getTranslations
            
            puts colored :blue, "\n#{CHAR_FLAG} Downloading translations from prontalize API ..."
            
            prontalizeUri = URI.parse(PRONTALIZE_HOST)

            http = Net::HTTP.new(prontalizeUri.host, prontalizeUri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            request = Net::HTTP::Get.new("/api/projects/#{@prontalizeProjectId}/translation_keys")
            request.add_field('Content-Type', 'application/json')
            request.add_field('Authorization', "Bearer #{@prontalizeApiKey}")
            response = http.request(request)
            body = response.body

            begin
                json = JSON.parse(body)
            rescue JSON::ParserError => error
                warn colored :red, "#{CHAR_ERROR} Error parsing JSON: #{error}"
                exit
            end

            translations = json["data"]
            if translations.nil?
                warn colored :red, "#{CHAR_ERROR} Invalid JSON, key 'translations' not present"
                exit
            end
            
            return translations
        end

        def parse(translations)
            puts colored :blue, "\n#{CHAR_FLAG} Parsing translations"
            
            allowedLocales = [ "nl-BE", "de-CH", "fr-BE", "da", "da_DK", "de", "de-AT", "de_AT", "el", "en-AU", "en-CA", "en-GB", "en-US", "es", "es-MX", "fi", "fr-CA", "fr", "id", "it", "ja", "ko", "ms", "nl", "no", "pt-BR", "pt", "ru", "sv", "th", "tr", "vi", "zh-Hans", "zh-Hant", "appleTV", "iMessage", "default" ]
            allowedLocales.each { |loc| 
              if loc.length == 2
                allowedLocales << "#{loc}-#{loc.upcase}"
              end
            }
            
            appstoreKeyMapping = {
                "appstore.app.title" => [ "name", 30 ],
                "appstore.app.promotionaltext" => [ "promotional_text", 170 ],
                "appstore.app.keywords" => [ "keywords", 100 ],
                "appstore.app.subtitle" => [ "subtitle", 30 ],
                "appstore.app.description" => [ "description", 4000 ],
                "appstore.app.whatsnew" => [ "release_notes", 4000 ]
            }

            filesToWrite = {}
            handledUnsupportedLocals = []

            translations.each do |translation|
                unless type = translation["key_type"]
                    next
                end
                unless key = translation["identifier"]
                    next
                end

                translation["translations"].each do |languageTranslation|
                    unless locale = languageTranslation["locale"]
                        next
                    end

                    text = languageTranslation["value"] || ""
                    line = {'key' => key, 'translation' => text}
                    filenameSuffix = locale

                    case type
                    when "store"
                        localeWithDash = "#{locale}".gsub("_", "-")

                        # Switch the locale to en-GB if the en-US dir doesn't exist
                        if localeWithDash == "en-US"
                            unless Dir.exists? "ios/fastlane/metadata/#{localeWithDash}"
                                localeWithDash = "en-GB"
                            end
                        end

                        # If we received a locale we aren't aware of, manually update it to lower-UPPER: nl-NL
                        if localeWithDash.length == 2 && !allowedLocales.include?(locale)
                        localeWithDash = "#{locale}-#{locale.upcase}"
                        if locale == "en"
                            localeWithDash = "en-US"
                            unless Dir.exists? "ios/fastlane/metadata/#{localeWithDash}"
                                localeWithDash = "en-GB"
                            end
                        end
                        end

                        # Last check if we are able to handle the locale
                        if !allowedLocales.include?(localeWithDash) && !allowedLocales.include?(locale)
                        unless handledUnsupportedLocals.include?(locale)
                            handledUnsupportedLocals << locale
                            warn colored :red, "#{CHAR_WARNING} Warning: Unsupported appstore locale: '#{localeWithDash}'"
                        end
                        next
                        end

                        puts colored :default, "#{CHAR_VERBOSE} Store text: #{text}" unless !$verbose

                        length = appstoreKeyMapping[key][1]
                        unless filename = appstoreKeyMapping[key][0]
                            next
                        end

                        file = "ios/fastlane/metadata/#{localeWithDash}/#{filename}.txt"

                        # Cut off the string at max length for this key
                        line = text[(0..(length - 1))]

                    when "metadata"
                        file = "#{XCODE_RESOURCES_PATH}/#{filenameSuffix}.lproj/InfoPlist.strings"
                    else
                        file = "#{TRANSLATIONS_PATH}/app_#{filenameSuffix}.arb"
                    end

                    if file.end_with?(".strings")
                        filesToWrite[file] ||= []
                        filesToWrite[file] << "\"#{key}\" = \"#{transformForPlist(text)}\";"
                    elsif file.end_with?(".txt") 
                        filesToWrite[file] ||= []
                        filesToWrite[file] << line
                    else
                        filesToWrite[file] ||= {}
                        filesToWrite[file][line['key']] = line['translation']
                    end
                end
            end

        # Add fallback files for region-specific locales if base doesn't exist
        arb_locales = filesToWrite.keys.select { |f| f.end_with?('.arb') }
        locale_bases = arb_locales.map { |f| f.match(/app_(.+)\.arb/)[1] rescue nil }.compact

        # Map from region-specific (like 'da_DK') to base ('da')
        region_locales = locale_bases.select { |l| l.include?('_') }
        region_locales.each do |region_locale|
            base_locale = region_locale.split('_')[0]
            base_file = "#{TRANSLATIONS_PATH}/app_#{base_locale}.arb"

            unless locale_bases.include?(base_locale)
                puts colored :yellow, "#{CHAR_WARNING} Creating fallback ARB for #{base_locale}"

                # Copy the region-specific file as the base
                filesToWrite[base_file] = filesToWrite["#{TRANSLATIONS_PATH}/app_#{region_locale}.arb"].dup

                # Optionally, add the @@locale key
                filesToWrite[base_file]["@@locale"] = base_locale
            end
        end

            return filesToWrite
        end

        def write(files)
            puts colored :blue, "\n#{CHAR_FLAG} Writing files"

            files.each do |file, content|
                dir = File.dirname(file)
                puts colored :default, "#{CHAR_VERBOSE} Writing to '#{Pathname.new(dir).basename.to_s}/#{File.basename(file)}'" unless !$verbose

                unless File.directory?(dir)
                    FileUtils.mkdir_p dir
                end

                openedFile = File.new(file, 'w+')
                if file.end_with?(".strings") || file.end_with?(".txt")
                    content.each do |line|
                        openedFile.write("#{line}\n")
                    end
                else
                    openedFile.write(content.to_json)
                end
            
                openedFile.close
            end
        end

        def transformForPlist(text)
            return text
                .gsub("\r", "")
                .gsub("\\\r", "")
                .gsub("\n", "\\n")
                .gsub("\\\n", "\\n")
                .gsub("%s", "%@")
                .gsub("\"", "\\\"")
        end
    end
end