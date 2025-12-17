require 'rails_helper'

RSpec.describe WorkflowEvent, type: :model do
  let(:workflow) { Workflow.create!(name: 'Test Workflow') }

  describe 'validations' do
    it 'is valid with required attributes' do
      event = workflow.events.build(event_type: 'ticket_created', label: 'Start')
      expect(event).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a workflow' do
      association = described_class.reflect_on_association(:workflow)
      expect(association.macro).to eq :belongs_to
    end

    it 'has many nodes' do
      association = described_class.reflect_on_association(:nodes)
      expect(association.macro).to eq :has_many
    end

    it 'destroys nodes when destroyed' do
      event = workflow.events.create!(event_type: 'ticket_created', label: 'Start')
      event.nodes.create!(wf_node_id: 1, label: 'Start')
      
      expect { event.destroy }.to change(WorkflowNode, :count).by(-1)
    end
  end

  describe 'flow' do
    it 'defaults to empty hash' do
      event = workflow.events.create!(event_type: 'ticket_created', label: 'Start')
      expect(event.flow).to eq({})
    end

    it 'stores flow graph structure' do
      flow_data = { '1' => 10001, '10001' => { '1' => 20001 } }
      event = workflow.events.create!(
        event_type: 'ticket_created',
        label: 'Start',
        flow: flow_data
      )
      
      expect(event.flow).to eq(flow_data.stringify_keys)
    end
  end
end
