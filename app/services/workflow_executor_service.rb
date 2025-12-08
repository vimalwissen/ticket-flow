class WorkflowExecutorService
  def initialize(workflow_execution)
    @execution = workflow_execution
  end

  def run
    return unless @execution.status.in?(['pending', 'running'])

    @execution.update(status: 'running')

    event = @execution.workflow_event
    flow_map = event.flow # JSON adjacency list: { "1" => 20001, "20001" => { "1" => 20002 } }
    
    # Start: If execution is new, start at ID 1 (Event Node)
    current_id = @execution.current_wf_node_id || 1 

    while current_id
      @execution.log_step("Traversing Node ID: #{current_id}")
      
      # 1. Fetch Node Definition
      # For ID 1, we might not always have a WorkflowNode record if it's just a placeholder in flow,
      # but typically there should be a node.
      node = event.nodes.find_by(wf_node_id: current_id)
      
      unless node
        # If node not found but exists in flow (e.g. End State), stop.
        @execution.log_step("Node #{current_id} not found in DB. Stopping.")
        break 
      end

      # 2. Execute Node Logic
      processor = get_processor(node.node_type)
      result = processor.execute(node, @execution.context)
      
      # 3. Determine Next Node
      # flow entry for current_id can be: 
      # - Integer (Direct link)
      # - Hash (Branching based on result: "1" (True) or "0" (False))
      
      next_step = flow_map[current_id.to_s]
      
      if next_step.is_a?(Hash)
        # Branching
        key = result ? "1" : "0"
        current_id = next_step[key]
      elsif next_step.is_a?(Integer)
        # Direct
        current_id = next_step
      else
        # End of flow
        current_id = nil
      end

      # Update Execution State
      @execution.update(current_wf_node_id: current_id)
      
      if current_id.nil?
        @execution.update(status: 'completed')
        @execution.log_step("Workflow Completed")
      end
    end
  rescue StandardError => e
    @execution.update(status: 'failed')
    @execution.log_step("Error: #{e.message}")
    raise e
  end

  private

  def get_processor(type)
    case type.to_s
    when 'condition'
      Workflow::Processors::Condition.new
    when 'action'
      Workflow::Processors::Action.new
    else
      # Default/Event processor (No-op)
      Workflow::Processor.new 
    end
  end
end
