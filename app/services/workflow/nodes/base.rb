class Workflow
  module Nodes
    class Base
      def execute(node, context)
        raise NotImplementedError, "#{self.class.name} must implement #execute"
      end
    end
  end
end
