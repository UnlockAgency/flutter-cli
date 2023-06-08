require 'highline'

module Commands
    class Create
        attr_accessor :project_name    

        def initialize(args)
            # @project_name = args['project-name']

            puts args
        end

        def execute
            cli = HighLine.new
        end
    end
end
