require 'rails_helper'

RSpec.describe Workflow::Nodes::Action do
  let(:workflow) { Workflow.create!(name: 'Test', status: 1) }
  let(:event) { workflow.events.create!(event_type: 'ticket_created', label: 'Start') }
  let(:user) { User.find_or_create_by!(email: 'test@example.com', name: 'Test') { |u| u.password = 'password' } }
  let(:agent) { User.find_or_create_by!(email: 'agent@example.com', name: 'Agent') { |u| u.password = 'password' } }
  let(:ticket) do
    Ticket.create!(
      title: 'Test Request',
      description: 'Help needed',
      requestor: user.email,
      assign_to: agent.email,
      status: 'open',
      priority: 'low',
      source: 'email'
    )
  end

  subject { described_class.new }

  describe '#execute' do
    context 'set action_type' do
      let(:node) do
        event.nodes.create!(
          wf_node_id: 20001,
          label: 'Set Priority',
          data: { 'field' => 'priority', 'action_type' => 'set', 'value' => 'high' }
        )
      end

      it 'updates the specified field' do
        expect(ticket.priority).to eq('low')
        
        subject.execute(node, ticket)
        ticket.reload
        
        expect(ticket.priority).to eq('high')
      end

      it 'returns "1" on success' do
        result = subject.execute(node, ticket)
        expect(result).to eq('1')
      end
    end

    context 'set status' do
      let(:node) do
        event.nodes.create!(
          wf_node_id: 20002,
          label: 'Set Status',
          data: { 'field' => 'status', 'action_type' => 'set', 'value' => 'in_progress' }
        )
      end

      it 'updates the status field' do
        subject.execute(node, ticket)
        ticket.reload
        
        expect(ticket.status).to eq('in_progress')
      end
    end

    context 'invalid context' do
      let(:node) do
        event.nodes.create!(wf_node_id: 20001, label: 'Test', data: {})
      end

      it 'returns "0" when context is not a ticket' do
        expect(subject.execute(node, 'not_a_ticket')).to eq('0')
      end
    end

    context 'missing configuration' do
      let(:node) do
        event.nodes.create!(wf_node_id: 20001, label: 'Test', data: {})
      end

      it 'returns "0" when configuration is missing' do
        expect(subject.execute(node, ticket)).to eq('0')
      end
    end
  end
end
