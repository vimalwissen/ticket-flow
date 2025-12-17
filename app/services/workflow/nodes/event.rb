class Workflow
  module Nodes
    class Event < Base
      def execute(node, context)
        Rails.logger.info "Execute Event: #{node.label}"
        # Events are entry points, usually no-op logic during execution traversal
        "1"
      end
    end
  end
end
