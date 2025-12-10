class Workflow
  module Executors
    class Factory
      def self.build(node)
        case node.node_type.to_s
        when 'action'
          Workflow::Executors::Action.new
        when 'condition'
          Workflow::Executors::Condition.new
        when 'event'
          Workflow::Executors::Event.new
        when 'orchestration'
          Workflow::Executors::Orchestration.new
        else
          Workflow::Executors::Base.new
        end
      end
    end
  end
end
