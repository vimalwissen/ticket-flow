class Workflow
  class Processor
    def execute(event, context)
      # 1. Find the starting Event Node
      current_node = event.nodes.find_by(node_type: 'event') || event.nodes.first
      return unless current_node

      # 2. Traversal Loop
      loop do
        # Execute the current node's logic
        # REFACTORED: Use Services instead of Models
        executor = Workflow::Nodes::Factory.build(current_node)
        result = executor.execute(current_node, context)

        # 3. Determine Next Node ID from Flow
        next_node_id = get_next_node_id(event.flow, current_node.wf_node_id, result)
        break unless next_node_id

        # 4. Fetch Next Node
        current_node = event.find_node(next_node_id)
        break unless current_node
      end
    end

    private

    def get_next_node_id(flow, current_id, result)
      return nil unless flow
      
      step = flow[current_id.to_s]
      return nil unless step

      if step.is_a?(Hash)
        # Branching logic: lookup next ID based on result key
        step[result.to_s]
      else
        # Linear logic: step is the next ID
        step
      end
    end
  end
end
