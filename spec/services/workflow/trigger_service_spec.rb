require 'rails_helper'

RSpec.describe Workflow::TriggerService do
  let(:user) { User.create!(email: 'test@example.com', name: 'Test', password: 'password') }
  let(:agent) { User.create!(email: 'agent@example.com', name: 'Agent', password: 'password') }

  describe '#call' do
    context 'with active workflows' do
      let!(:workflow) { Workflow.create!(name: 'VIP Handler', status: 1) }
      let!(:event) do
        workflow.events.create!(
          event_type: 'ticket_created',
          label: 'Ticket Created',
          flow: { '1' => 10001, '10001' => { '1' => 20001, '0' => nil }, '20001' => nil }
        )
      end

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

      it 'triggers workflows for matching event type' do
        ticket = Ticket.new(
          title: 'VIP Request',
          description: 'Help',
          requestor: user.email,
          assign_to: agent.email,
          status: 'open',
          priority: 'low',
          source: 'email'
        )
        
        # Allow all logger calls, then specifically expect the triggering message
        allow(Rails.logger).to receive(:info)
        expect(Rails.logger).to receive(:info).with(/Triggering Workflow/).at_least(:once)
        described_class.call('ticket_created', ticket)
      end

      it 'does not trigger draft workflows' do
        workflow.update!(status: 2)
        ticket = Ticket.new(title: 'VIP', priority: 'low')
        
        allow(Rails.logger).to receive(:info)
        expect(Rails.logger).not_to receive(:info).with(/Triggering Workflow/)
        described_class.call('ticket_created', ticket)
      end
    end

    context 'with no matching workflows' do
      it 'does nothing when no workflows exist' do
        ticket = Ticket.new(title: 'Test')
        expect { described_class.call('ticket_created', ticket) }.not_to raise_error
      end
    end
  end
end
