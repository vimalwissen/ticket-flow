require 'swagger_helper'

RSpec.describe 'Workflows API', type: :request do
  let(:auth_user) { User.find_or_create_by!(email: 'admin@example.com', name: 'Admin') { |u| u.password = 'password' } }
  let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: auth_user.id)}" }

  path '/api/version1/workflows' do
    get 'Lists all Workflows' do
      tags 'Workflows'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'list of workflows' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              description: { type: :string, nullable: true },
              status: { type: :integer },
              module_id: { type: :integer },
              workspace_id: { type: :integer, nullable: true },
              created_at: { type: :string, format: 'date-time' },
              positions: { type: :object, additionalProperties: true },
              events: { 
                type: :object,
                additionalProperties: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    event_type: { type: :string },
                    entry_node: { type: :string },
                    nodes: { 
                      type: :object,
                      additionalProperties: {
                        type: :object,
                        properties: {
                          id: { type: :string },
                          label: { type: :string },
                          type: { type: :string },
                          ports: { 
                            type: :object,
                            properties: {
                              inputs: { type: :array, items: { type: :string } },
                              outputs: { type: :array, items: { type: :string } }
                            }
                          },
                          data: { type: :object, additionalProperties: true }
                        }
                      }
                    },
                    connections: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          from: { 
                            type: :object,
                            properties: {
                              node: { type: :string },
                              port: { type: :string }
                            }
                          },
                          to: {
                            type: :object,
                            properties: {
                              node: { type: :string },
                              port: { type: :string }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }

        let!(:workflow) { Workflow.create!(name: 'Demo', status: 1, module_id: 1) }
        run_test!
      end
    end

    post 'Creates a Workflow' do
      tags 'Workflows'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :workflow, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string },
          positions: { type: :object },
          events: { type: :object }
        },
        required: [ 'name' ]
      }

      response '201', 'workflow created' do
        let(:workflow) { { name: 'New Workflow', description: 'Test', positions: { '1' => { x: 0, y: 0 } } } }
        run_test!
      end
    end
  end

  path '/api/version1/workflows/{id}' do
    get 'Retrieves a Workflow' do
      tags 'Workflows'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string

      response '200', 'workflow found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            description: { type: :string, nullable: true },
            status: { type: :integer },
            module_id: { type: :integer },
            workspace_id: { type: :integer, nullable: true },
            created_at: { type: :string, format: 'date-time' },
            positions: { type: :object },
            events: { type: :object }
          }
        
        let(:wf) { Workflow.create!(name: 'Demo', status: 1, module_id: 1) }
        let(:id) { wf.id }
        run_test!
      end

      response '404', 'workflow not found' do
        let(:id) { 999999 }
        run_test!
      end
    end

    put 'Updates a Workflow' do
      tags 'Workflows'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string
      parameter name: :workflow, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          positions: { type: :object }
        }
      }

      response '200', 'workflow updated' do
        let(:wf) { Workflow.create!(name: 'Demo', status: 1) }
        let(:id) { wf.id }
        let(:workflow) { { name: 'Updated Name', positions: { '1' => { x: 10, y: 10 } } } }
        run_test!
      end
    end

    delete 'Deletes a Workflow' do
      tags 'Workflows'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string

      response '204', 'workflow deleted' do
        let(:wf) { Workflow.create!(name: 'Demo', status: 1) }
        let(:id) { wf.id }
        run_test!
      end
    end
  end
end
