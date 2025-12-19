require 'rails_helper'

RSpec.describe Workflow::Processor do
  let(:workflow) { Workflow.create!(name: 'Test Workflow', status: 1) }
  let(:event) do
    workflow.events.create!(
      event_type: 'ticket_created',
      label: 'Start',
      flow: { '1' => 10001, '10001' => { '1' => 20001, '0' => nil }, '20001' => nil }
    )
  end
  let(:user) { User.find_or_create_by!(email: 'test@example.com', name: 'Test') { |u| u.password = 'password' } }
  let(:agent) { User.find_or_create_by!(email: 'agent@example.com', name: 'Agent') { |u| u.password = 'password' } }

  before do
    event.nodes.create!(wf_node_id: 1, label: 'Start')
    event.nodes.create!(
      wf_node_id: 10001,
      label: 'Check VIP',
      data: { 'field' => 'title', 'operator' => 'contains', 'value' => 'VIP' }
    )
    event.nodes.create!(
      wf_node_id: 20001,
      label: 'Set Priority',
      data: { 'field' => 'priority', 'action_type' => 'set', 'value' => 'high' }
    )
  end

  describe '#execute' do
    context 'when condition is true' do
      it 'executes the action node' do
        ticket = Ticket.create!(
          title: 'VIP Request',
          description: 'Help',
          requestor: user.email,
          assign_to: agent.email,
          status: 'open',
          priority: 'low',
          source: 'email'
        )

        described_class.new.execute(event, ticket)
        ticket.reload
        
        expect(ticket.priority).to eq('high')
      end
    end

    context 'when condition is false' do
      it 'does not execute the action node' do
        ticket = Ticket.create!(
          title: 'Normal Request',
          description: 'Help',
          requestor: user.email,
          assign_to: agent.email,
          status: 'open',
          priority: 'low',
          source: 'email'
        )

        described_class.new.execute(event, ticket)
        ticket.reload
        
        expect(ticket.priority).to eq('low')
      end
    end
  end
end
