class Workflow
  module Executors
    class Base
      def execute(node, context)
        # Default implementation returns "1" (success)
        "1"
      end
    end
  end
end
