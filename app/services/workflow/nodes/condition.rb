class Workflow
  module Nodes
    class Condition < Base
      def execute(node, context)
        Rails.logger.info "Execute Condition: #{node.label} (Data: #{node.data})"

        # 1. Validate Context
        unless context.is_a?(Ticket)
          Rails.logger.warn "Condition Node: Context is not a Ticket"
          return "0"
        end

        # 2. Extract Configuration
        field_name = node.data['field']
        operator   = node.data['operator']
        target_val = node.data['value']

        if field_name.blank? || operator.blank?
          Rails.logger.warn "Condition Node: Missing configuration (field or operator)"
          return "0" # Default fail/false
        end

        # 3. Fetch Actual Value from Ticket
        unless context.respond_to?(field_name)
          Rails.logger.warn "Condition Node: Ticket does not respond to '#{field_name}'"
          return "0"
        end
        
        actual_val = context.public_send(field_name).to_s

        # 4. Evaluate
        result = evaluate(actual_val, operator, target_val.to_s)
        
        Rails.logger.info "  Check: '#{actual_val}' #{operator} '#{target_val}' => #{result}"
        result ? "1" : "0"
      end

      private

      def evaluate(actual, operator, expected)
        case operator.downcase
        when 'equals', '=='
          actual == expected
        when 'not_equals', '!='
          actual != expected
        when 'contains', 'include'
          actual.include?(expected)
        when 'starts_with'
          actual.start_with?(expected)
        when 'ends_with'
          actual.end_with?(expected)
        else
          false
        end
      end
    end
  end
end
