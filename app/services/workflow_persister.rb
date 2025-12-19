class WorkflowPersister
  def initialize(workflow, params)
    @workflow = workflow
    @params = params
  end

  def persist
    ActiveRecord::Base.transaction do
      update_workflow
      persist_positions
      persist_events
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    @workflow.errors.add(:base, e.message)
    false
  end

  private

  def update_workflow
    @workflow.assign_attributes(@params.slice(:name, :description, :module_id, :workspace_id, :status))
    @workflow.save!
  end

  def persist_positions
    return unless @params[:positions]
    
    config = @workflow.additional_config || {}
    config["positions"] = @params[:positions]
    @workflow.update!(additional_config: config)
  end

  def persist_events
    return unless @params[:events]

    @params[:events].each do |event_type, event_data|
      event = @workflow.events.find_or_initialize_by(event_type: event_type)
      event.label = event_data[:label] || event_type.humanize
      event.save!

      # Persist Nodes first to ensure they exist
      persist_nodes(event, event_data[:nodes])
      
      # Then persist connections (flow)
      persist_flow(event, event_data[:connections])
    end
  end

  def persist_nodes(event, nodes_data)
    current_node_ids = []
    
    nodes_data.each do |node_id_str, node_data|
      # node_id_str matches wf_node_id
      wf_node_id = node_data[:id].to_i
      
      node = event.nodes.find_or_initialize_by(wf_node_id: wf_node_id)
      node.label = node_data[:label]
      node.data = node_data[:data] || {}
      # node_type is derived from ID range in model, but we could set it if ensuring consistency
      
      node.save!
      current_node_ids << node.id
    end

    # Helper to clean up nodes that are removed? 
    # For now, we won't delete nodes implicitly to avoid data loss during partial updates, 
    # but strictly speaking a full update should probably remove missing nodes.
    # event.nodes.where.not(id: current_node_ids).destroy_all
  end

  def persist_flow(event, connections)
    flow_map = {}

    connections.each do |conn|
      from_node = conn.dig(:from, :node).to_s
      from_port = conn.dig(:from, :port)
      to_node = conn.dig(:to, :node).to_i

      if from_port == 'yes' || from_port == 'no'
        # Condition node
        flow_map[from_node] ||= {}
        # If it was initialized as integer (direct link), force to hash? Should not happen if valid.
        flow_map[from_node] = {} unless flow_map[from_node].is_a?(Hash)
        
        condition_key = (from_port == 'yes') ? '1' : '0'
        flow_map[from_node][condition_key] = to_node
      else
        # Standard transition
        flow_map[from_node] = to_node
      end
    end

    event.update!(flow: flow_map)
  end
end
