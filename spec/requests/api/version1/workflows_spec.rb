require 'swagger_helper'

RSpec.describe 'Workflows API', type: :request do
  let(:auth_user) { User.create!(email: 'admin@example.com', name: 'Admin', password: 'password') }
  let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: auth_user.id)}" }

  path '/api/version1/workflows' do
    get 'Lists all Workflows' do
      tags 'Workflows'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'list of workflows' do
        let!(:workflow) { Workflow.create!(name: 'Demo', status: 1) }
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
        let(:wf) { Workflow.create!(name: 'Demo', status: 1) }
        let(:id) { wf.id }
        run_test!
      end

      response '404', 'workflow not found' do
        let(:id) { 999999 }
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
