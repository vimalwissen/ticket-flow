require 'swagger_helper'

RSpec.describe 'Ticket Automators API', type: :request do
  let(:auth_user) { User.find_or_create_by!(email: 'admin@example.com', name: 'Admin') { |u| u.password = 'password' } }
  let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: auth_user.id)}" }

  path '/api/version1/ticket_automators' do
    post 'Creates a Ticket Automator (Workflow)' do
      tags 'Ticket Automators'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :workflow, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string },
          workspace_id: { type: :integer },
          workflow_type: { type: :string }
        },
        required: [ 'name' ]
      }

      response '201', 'workflow created' do
        let(:workflow) { { name: 'New Workflow', description: 'Test', workspace_id: 1 } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:workflow) { { name: '' } }
        run_test!
      end
    end
  end

  path '/api/version1/ticket_automators/{id}' do
    put 'Updates a Ticket Automator' do
      tags 'Ticket Automators'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string
      parameter name: :workflow, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string },
          status: { type: :integer }
        }
      }

      response '200', 'workflow updated' do
        let(:wf) { Workflow.create!(name: 'Draft', status: 2) }
        let(:id) { wf.id }
        let(:workflow) { { name: 'Updated Name' } }
        run_test!
      end
    end
  end

  path '/api/version1/ticket_automators/{id}/event' do
    post 'Creates an Event Node' do
      tags 'Ticket Automators'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string
      parameter name: :event_params, in: :body, schema: {
        type: :object,
        properties: {
          label: { type: :string },
          wf_node: { type: :integer },
          data: { type: :string, description: 'JSON string of node data' },
          x: { type: :integer },
          y: { type: :integer }
        },
        required: ['label', 'wf_node'],
        example: {
          label: "Ticket is raised",
          wf_node: "1",
          data: "{}",
          x: 100,
          y: 100
        }
      }

      response '200', 'event created' do
        let(:wf) { Workflow.create!(name: 'Draft', status: 2) }
        let(:id) { wf.id }
        let(:event_params) { { label: 'Start', wf_node: 1, x: 100, y: 100 } }
        run_test!
      end
    end
  end

  path '/api/version1/ticket_automators/{id}/node' do
    put 'Creates a Logic Node' do
      tags 'Ticket Automators'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string
      parameter name: :node_params, in: :body, schema: {
        type: :object,
        properties: {
          label: { type: :string },
          wf_node: { type: :integer },
          data: { type: :string, description: 'JSON string of node data' },
          prev_node: {
            type: :object,
            properties: {
              id: { type: :integer },
              condition: { type: :string }
            }
          },
          x: { type: :integer },
          y: { type: :integer }
        },
        required: ['label', 'wf_node', 'prev_node'],
        example: {
          label: "Category is Payroll?",
          wf_node: "30001",
          data: "{}",
          prev_node: {
            id: "1",
            condition: ""
          },
          x: 400,
          y: 100
        }
      }

      response '200', 'node created' do
        let(:wf) { Workflow.create!(name: 'Draft', status: 2) }
        let!(:event) { wf.events.create!(event_type: 'ticket_created', label: 'Start') }
        let!(:start_node) { event.nodes.create!(wf_node_id: 1, label: 'Start') }
        let(:id) { wf.id }
        let(:node_params) { { 
          label: 'Check Priority', 
          wf_node: 10001, 
          prev_node: { id: 1 },
          x: 200, 
          y: 100 
        } }
        run_test!
      end
    end
  end

  path '/api/version1/ticket_automators/{id}/publish' do
    put 'Publishes the Workflow' do
      tags 'Ticket Automators'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string

      response '200', 'workflow published' do
        let(:wf) { Workflow.create!(name: 'To Publish', status: 2) }
        let(:id) { wf.id }
        run_test!
      end
    end
  end
end
