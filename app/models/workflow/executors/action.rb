class Workflow
  module Executors
    class Action < Base
      def execute(node, context)
        Rails.logger.info "Execute Action: #{node.label} (Data: #{node.data})"

        # 1. Validate Context
        unless context.is_a?(Ticket)
           Rails.logger.warn "Action Executor: Context is not a Ticket"
           return "0"
        end

        # 2. Extract Configuration
        field_name  = node.data['field']
        action_type = node.data['action_type']
        value       = node.data['value']

        if field_name.blank? || action_type.blank?
           Rails.logger.warn "Action Executor: Missing configuration"
           return "0"
        end

        # 3. Perform Action
        case action_type.downcase
        when 'set'
          if context.respond_to?("#{field_name}=")
             # Simple type casting could go here, but relying on Active Record coercion for now
             context.update(field_name => value)
             Rails.logger.info "  Action: Set #{field_name} to '#{value}'"
          else
             Rails.logger.warn "  Action: Cannot set attribute '#{field_name}'"
          end
        else
          Rails.logger.warn "  Action: Unknown action type '#{action_type}'"
        end

        "1"
      end
    end
  end
end
