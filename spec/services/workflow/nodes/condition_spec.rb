require 'rails_helper'

RSpec.describe Workflow::Nodes::Condition do
  let(:workflow) { Workflow.create!(name: 'Test', status: 1) }
  let(:event) { workflow.events.create!(event_type: 'ticket_created', label: 'Start') }
  let(:user) { User.find_or_create_by!(email: 'test@example.com', name: 'Test') { |u| u.password = 'password' } }
  let(:agent) { User.find_or_create_by!(email: 'agent@example.com', name: 'Agent') { |u| u.password = 'password' } }
  let(:ticket) do
    Ticket.create!(
      title: 'VIP Customer Request',
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
    context 'equals operator' do
      let(:node) do
        event.nodes.create!(
          wf_node_id: 10001,
          label: 'Check Priority',
          data: { 'field' => 'priority', 'operator' => 'equals', 'value' => 'low' }
        )
      end

      it 'returns "1" when values match' do
        expect(subject.execute(node, ticket)).to eq('1')
      end

      it 'returns "0" when values do not match' do
        node.data['value'] = 'high'
        expect(subject.execute(node, ticket)).to eq('0')
      end
    end

    context 'contains operator' do
      let(:node) do
        event.nodes.create!(
          wf_node_id: 10001,
          label: 'Check Title',
          data: { 'field' => 'title', 'operator' => 'contains', 'value' => 'VIP' }
        )
      end

      it 'returns "1" when value is contained' do
        expect(subject.execute(node, ticket)).to eq('1')
      end

      it 'returns "0" when value is not contained' do
        node.data['value'] = 'URGENT'
        expect(subject.execute(node, ticket)).to eq('0')
      end
    end

    context 'starts_with operator' do
      let(:node) do
        event.nodes.create!(
          wf_node_id: 10001,
          label: 'Check Title',
          data: { 'field' => 'title', 'operator' => 'starts_with', 'value' => 'VIP' }
        )
      end

      it 'returns "1" when title starts with value' do
        expect(subject.execute(node, ticket)).to eq('1')
      end
    end

    context 'ends_with operator' do
      let(:node) do
        event.nodes.create!(
          wf_node_id: 10001,
          label: 'Check Title',
          data: { 'field' => 'title', 'operator' => 'ends_with', 'value' => 'Request' }
        )
      end

      it 'returns "1" when title ends with value' do
        expect(subject.execute(node, ticket)).to eq('1')
      end
    end

    context 'not_equals operator' do
      let(:node) do
        event.nodes.create!(
          wf_node_id: 10001,
          label: 'Check Priority',
          data: { 'field' => 'priority', 'operator' => 'not_equals', 'value' => 'high' }
        )
      end

      it 'returns "1" when values do not match' do
        expect(subject.execute(node, ticket)).to eq('1')
      end
    end

    context 'invalid context' do
      let(:node) do
        event.nodes.create!(wf_node_id: 10001, label: 'Test', data: {})
      end

      it 'returns "0" when context is not a ticket' do
        expect(subject.execute(node, 'not_a_ticket')).to eq('0')
      end
    end
  end
end
