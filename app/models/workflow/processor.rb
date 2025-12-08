module Workflow
  class Processor
    def execute(node, context)
      raise NotImplementedError
    end
  end
end
