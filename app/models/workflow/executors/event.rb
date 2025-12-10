class Workflow
  module Executors
    class Event < Base
      def execute(node, context)
        puts "Execute Event: #{node.label}"
        "1"
      end
    end
  end
end
