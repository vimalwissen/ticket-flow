require 'rails_helper'

RSpec.describe 'Workflow Integration', type: :request do
  let(:user) { User.find_or_create_by!(email: 'customer@example.com', name: 'Customer') { |u| u.password = 'password' } }
  let(:agent) { User.find_or_create_by!(email: 'agent@example.com', name: 'Agent') { |u| u.password = 'password' } }

  describe 'Ticket Creation Triggers Workflow' do
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

    it 'updates priority when VIP condition matches' do
      ticket = Ticket.create!(
        title: 'Urgent VIP Request',
        description: 'Help me',
        requestor: user.email,
        assign_to: agent.email,
        status: 'open',
        priority: 'low',
        source: 'email'
      )

      ticket.reload
      expect(ticket.priority).to eq('high')
    end

    it 'does not update priority when VIP condition does not match' do
      ticket = Ticket.create!(
        title: 'Normal Request',
        description: 'Help me',
        requestor: user.email,
        assign_to: agent.email,
        status: 'open',
        priority: 'low',
        source: 'email'
      )

      ticket.reload
      expect(ticket.priority).to eq('low')
    end

    it 'does not trigger when workflow is draft' do
      workflow.update!(status: 2)

      ticket = Ticket.create!(
        title: 'VIP Request',
        description: 'Help me',
        requestor: user.email,
        assign_to: agent.email,
        status: 'open',
        priority: 'low',
        source: 'email'
      )

      ticket.reload
      expect(ticket.priority).to eq('low')
    end
  end

  describe 'Multiple Workflows' do
    let!(:vip_workflow) { Workflow.create!(name: 'VIP Handler', status: 1) }
    let!(:urgent_workflow) { Workflow.create!(name: 'Urgent Handler', status: 1) }

    before do
      # VIP Workflow
      vip_event = vip_workflow.events.create!(
        event_type: 'ticket_created',
        label: 'VIP Check',
        flow: { '1' => 10001, '10001' => { '1' => 20001, '0' => nil }, '20001' => nil }
      )
      vip_event.nodes.create!(wf_node_id: 1, label: 'Start')
      vip_event.nodes.create!(
        wf_node_id: 10001,
        label: 'Check VIP',
        data: { 'field' => 'title', 'operator' => 'contains', 'value' => 'VIP' }
      )
      vip_event.nodes.create!(
        wf_node_id: 20001,
        label: 'Set High Priority',
        data: { 'field' => 'priority', 'action_type' => 'set', 'value' => 'high' }
      )

      # Urgent Workflow  
      urgent_event = urgent_workflow.events.create!(
        event_type: 'ticket_created',
        label: 'Urgent Check',
        flow: { '1' => 10002, '10002' => { '1' => 20002, '0' => nil }, '20002' => nil }
      )
      urgent_event.nodes.create!(wf_node_id: 1, label: 'Start')
      urgent_event.nodes.create!(
        wf_node_id: 10002,
        label: 'Check Urgent',
        data: { 'field' => 'title', 'operator' => 'contains', 'value' => 'URGENT' }
      )
      urgent_event.nodes.create!(
        wf_node_id: 20002,
        label: 'Set Critical Status',
        data: { 'field' => 'status', 'action_type' => 'set', 'value' => 'in_progress' }
      )
    end

    it 'triggers multiple matching workflows' do
      ticket = Ticket.create!(
        title: 'VIP URGENT Request',
        description: 'Help me',
        requestor: user.email,
        assign_to: agent.email,
        status: 'open',
        priority: 'low',
        source: 'email'
      )

      ticket.reload
      expect(ticket.priority).to eq('high')
      expect(ticket.status).to eq('in_progress')
    end
  end
end
