class Workflow
  module Executors
    class Action < Base
      def execute(node, context)
        # In a real app, logic would use node.data to determine the action
        # e.g. "set_priority" -> context.ticket.update(priority: 'high')
        
        puts "Execute Action: #{node.label}"
        
        # DEMO LOGIC:
        if node.label == "Subject contains VIP"
          # Treating this as a check for the demo case provided
          return context.respond_to?(:subject) && context.subject.include?("VIP") ? "1" : "0"
        elsif node.label == "Set Priority High"
          if context.respond_to?(:priority=)
             context.priority = 4 # High
             context.save if context.respond_to?(:save)
          end
        end

        "1"
      end
    end
  end
end
