class WorkflowSerializer
  def initialize(workflow)
    @workflow = workflow
  end

  def as_json
    {
      id: @workflow.id,
      name: @workflow.name,
      description: @workflow.description,
      status: @workflow.status,
      module_id: @workflow.module_id,
      workspace_id: @workflow.workspace_id,
      created_at: @workflow.created_at,
      positions: positions,
      events: events_hash
    }
  end

  private

  def positions
    # Fetch positions from additional_config or return empty hash
    (@workflow.additional_config || {})["positions"] || {}
  end

  def events_hash
    # Map events keyed by event_type
    @workflow.events.each_with_object({}) do |event, hash|
      hash[event.event_type] = serialize_event(event)
    end
  end

  def serialize_event(event)
    {
      id: event.id,
      event_type: event.event_type,
      entry_node: find_entry_node(event)&.wf_node_id&.to_s,
      nodes: serialize_nodes(event),
      connections: serialize_connections(event.flow)
    }
  end

  def find_entry_node(event)
    # Heuristic: The node with ID 1 is usually the entry node in this system
    event.nodes.find_by(wf_node_id: 1)
  end

  def serialize_nodes(event)
    event.nodes.each_with_object({}) do |node, hash|
      hash[node.wf_node_id] = {
        id: node.wf_node_id.to_s,
        label: node.label,
        type: node.node_type,
        ports: derive_ports(node),
        data: node.data || {}
      }
    end
  end

  def derive_ports(node)
    # Simple heuristic for ports based on node type
    case node.node_type
    when 'event'
      { inputs: [], outputs: ['next'] }
    when 'condition'
      { inputs: ['in'], outputs: ['yes', 'no'] }
    when 'action'
      { inputs: ['in'], outputs: ['next'] }
    else
      { inputs: ['in'], outputs: [] }
    end
  end

  def serialize_connections(flow)
    connections = []
    return connections unless flow.is_a?(Hash)

    flow.each do |source_id, target_config|
      if target_config.is_a?(Hash)
        # Condition node: logical branches
        target_config.each do |condition_val, target_id|
          next unless target_id
          port_name = (condition_val.to_s == '1') ? 'yes' : 'no'
          connections << {
            from: { node: source_id.to_s, port: port_name },
            to: { node: target_id.to_s, port: 'in' }
          }
        end
      else
        # Simple transition
        next unless target_config
        connections << {
          from: { node: source_id.to_s, port: 'next' },
          to: { node: target_config.to_s, port: 'in' }
        }
      end
    end
    connections
  end
end
