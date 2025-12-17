require 'rails_helper'

RSpec.describe WorkflowNode, type: :model do
  let(:workflow) { Workflow.create!(name: 'Test Workflow') }
  let(:event) { workflow.events.create!(event_type: 'ticket_created', label: 'Start') }

  describe 'validations' do
    it 'requires wf_node_id' do
      node = event.nodes.build(label: 'Test')
      expect(node).not_to be_valid
    end

    it 'is valid with required attributes' do
      node = event.nodes.build(wf_node_id: 1, label: 'Start')
      expect(node).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a workflow_event' do
      association = described_class.reflect_on_association(:workflow_event)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe 'node_type derivation' do
    it 'derives event type for id 1-9999' do
      node = event.nodes.create!(wf_node_id: 1, label: 'Start')
      expect(node.node_type).to eq('event')
    end

    it 'derives condition type for id 10000-19999' do
      node = event.nodes.create!(wf_node_id: 10001, label: 'Check Priority')
      expect(node.node_type).to eq('condition')
    end

    it 'derives action type for id 20000-29999' do
      node = event.nodes.create!(wf_node_id: 20001, label: 'Set Priority')
      expect(node.node_type).to eq('action')
    end
  end

  describe 'data' do
    it 'defaults to empty hash' do
      node = event.nodes.create!(wf_node_id: 1, label: 'Start')
      expect(node.data).to eq({})
    end

    it 'stores condition configuration' do
      data = { 'field' => 'title', 'operator' => 'contains', 'value' => 'VIP' }
      node = event.nodes.create!(wf_node_id: 10001, label: 'Check', data: data)
      expect(node.data).to eq(data)
    end

    it 'stores action configuration' do
      data = { 'field' => 'priority', 'action_type' => 'set', 'value' => 'high' }
      node = event.nodes.create!(wf_node_id: 20001, label: 'Set Priority', data: data)
      expect(node.data).to eq(data)
    end
  end
end
