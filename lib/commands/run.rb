module Commands
    class Run < Commands::Buildable

        def initialize(args)
            super 
        end

        def execute
            super 

            select_device

            command = "flutter run #{@platform} --target=lib/main.dart --dart-define-from-file=config/.build.json --device-id #{@device}"
            command += @release ? " --release" : ""

            puts colored :blue, "\n#{CHAR_FLAG} Running app in flavor: #{@flavor}"
            puts colored :default, "#{command}\n\n"

            exec(command)
        end

        def select_device
            puts colored :blue, "\n#{CHAR_FLAG} Retrieving list of available devices"

            # Get devices
            output = `flutter devices`

            # output = [
            #     "2 devices connected\n",
            #     "\n",
            #     "iPhone 14 Pro (mobile) • 52A92D55-3040-483A-86AC-574E2E3985E0 • ios            • com.apple.CoreSimulator.SimRuntime.iOS-16-4 (simulator)\n",
            #     "SM S901B (mobile)         • RFCT712TPEX • android-arm64  • Android 13 (API 33)",
            #     "sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33) (emulator)",
            #     "macOS (desktop)        • macos                                • darwin-arm64   • macOS 13.2.1 22D68 darwin-arm64\n"
            # ]

            devices = []
            output.each_line do |line|
                if !line.include?("•")
                    next
                end

                device = line.split("•")
                
                if device.length < 3
                    next
                end

                devices.push({
                    name: device[0].strip,
                    id: device[1].strip,
                    platform: device[2].strip
                })
            end

            # Filter out devices who are incompatible with the selected platform
            devices = devices.select { |d| d[:platform].include? @platform }

            unless devices.length > 0
                warn colored :red, "\n#{CHAR_ERROR} Found no compatible device(s), available devices:"
                puts output
                exit
            end

            if devices.length > 1
                puts colored :default, "\n#{CHAR_VERBOSE} Found #{devices.length} compatible device(s)" unless !$verbose

                longestNameLength = devices.map { |d| d[:name].length }.max
                
                choices = []
                devices.each do |device|
                    choices.push({
                        name: sprintf("%-#{longestNameLength}s • %s", device[:name], device[:id]),
                        value: device[:id]
                    })
                end

                @device = @@prompt.select("What device should be used?", choices)
            else
                puts colored :default, "\n#{CHAR_VERBOSE} Running app on: #{devices[0][:name]}" unless !$verbose

                @device = devices[0][:id]
            end
        end
    end
end