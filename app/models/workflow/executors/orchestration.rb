class Workflow
  module Executors
    class Orchestration < Base
      def execute(node, context)
        puts "Execute Orchestration: #{node.label}"
        
        if node.label == "Set Priority High"
           # Fallback if mapped to Orchestration
           if context.respond_to?(:priority=)
             context.priority = 4
             context.save if context.respond_to?(:save)
           end
        end

        "1"
      end
    end
  end
end
