class Workflow
  module Nodes
    class Factory
      def self.build(node)
        case node.node_type.to_s
        when 'action'
          Workflow::Nodes::Action.new
        when 'condition'
          Workflow::Nodes::Condition.new
        when 'event'
          Workflow::Nodes::Event.new
        else
          # Fallback or Base
          Workflow::Nodes::Base.new
        end
      end
    end
  end
end
