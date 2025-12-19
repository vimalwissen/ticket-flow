require 'swagger_helper'

RSpec.describe 'Tickets API', type: :request do
  let(:user) { User.find_or_create_by!(email: 'customer@example.com', name: 'Customer') { |u| u.password = 'password' } }
  let(:agent) { User.find_or_create_by!(email: 'agent@example.com', name: 'Agent') { |u| u.password = 'password'; u.role = 'agent' } }
  let(:admin) { User.find_or_create_by!(email: 'admin@example.com', name: 'Admin') { |u| u.password = 'password'; u.role = 'admin' } }
  let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: admin.id, role: 'admin')}" }

  path '/api/version1/tickets' do
    get 'List all tickets' do
      tags 'Tickets'
      produces 'application/json'
      parameter name: :Authorization, in: :header, type: :string, required: true
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'
      parameter name: 'q[status_eq]', in: :query, type: :string, required: false, description: 'Filter by status'
      parameter name: 'q[priority_eq]', in: :query, type: :string, required: false, description: 'Filter by priority'

      response '200', 'Tickets retrieved' do
        schema type: :object, properties: {
          message: { type: :string },
          tickets: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :integer },
                ticket_id: { type: :string },
                title: { type: :string },
                description: { type: :string },
                status: { type: :string },
                priority: { type: :string },
                source: { type: :string },
                requestor: { type: :string },
                assign_to: { type: :string, nullable: true },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' }
              }
            }
          },
          meta: {
            type: :object,
            properties: {
              current_page: { type: :integer },
              next_page: { type: :integer, nullable: true },
              prev_page: { type: :integer, nullable: true },
              total_pages: { type: :integer },
              total_count: { type: :integer }
            }
          }
        }

        before do
          Ticket.create!(title: 'Test', description: 'Desc', requestor: user.email, status: 'open', priority: 'low', source: 'email')
        end

        run_test!
      end
    end

    post 'Create a ticket' do
      tags 'Tickets'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :Authorization, in: :header, type: :string, required: true
      parameter name: :ticket, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: 'Cannot login to system', maxLength: 100 },
          description: { type: :string, example: 'Getting error when trying to login', maxLength: 5000 },
          priority: { type: :string, enum: %w[low medium high], example: 'high' },
          source: { type: :string, enum: %w[email phone web chat], example: 'email' },
          requestor: { type: :string, example: 'customer@example.com' },
          assign_to: { type: :string, example: 'agent@example.com', nullable: true }
        },
        required: %w[title description requestor]
      }

      response '201', 'Ticket created' do
        schema type: :object, properties: {
          message: { type: :string, example: 'Ticket created successfully' },
          ticket: { type: :object }
        }

        let(:ticket) do
          {
            title: 'New Support Request',
            description: 'Need help with account',
            requestor: user.email,
            assign_to: agent.email,
            priority: 'high',
            source: 'email'
          }
        end

        run_test!
      end

      response '422', 'Validation errors' do
        schema type: :object, properties: {
          errors: { type: :array, items: { type: :string } }
        }

        let(:ticket) { { title: '', description: '', requestor: '' } }

        run_test!
      end
    end
  end

  path '/api/version1/tickets/{ticket_id}' do
    parameter name: :ticket_id, in: :path, type: :string, description: 'Ticket ID'
    parameter name: :Authorization, in: :header, type: :string, required: true

    let(:existing_ticket) do
      Ticket.create!(
        title: 'Existing Ticket',
        description: 'Description',
        requestor: user.email,
        assign_to: agent.email,
        status: 'open',
        priority: 'low',
        source: 'email'
      )
    end
    let(:ticket_id) { existing_ticket.ticket_id }

    get 'Get a ticket' do
      tags 'Tickets'
      produces 'application/json'

      response '200', 'Ticket found' do
        schema type: :object, properties: {
          message: { type: :string },
          ticket: {
            type: :object,
            properties: {
              id: { type: :integer },
              ticket_id: { type: :string },
              title: { type: :string },
              description: { type: :string },
              status: { type: :string },
              priority: { type: :string },
              source: { type: :string },
              requestor: { type: :string },
              assign_to: { type: :string, nullable: true }
            }
          }
        }

        run_test!
      end

      response '404', 'Ticket not found' do
        schema type: :object, properties: {
          error: { type: :string, example: 'Ticket not found' }
        }

        let(:ticket_id) { 'nonexistent' }

        run_test!
      end
    end

    put 'Update a ticket' do
      tags 'Tickets'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :ticket, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string },
          status: { type: :string, enum: %w[open in_progress on_hold resolved closed] },
          priority: { type: :string, enum: %w[low medium high] },
          assign_to: { type: :string, nullable: true }
        }
      }

      response '200', 'Ticket updated' do
        schema type: :object, properties: {
          message: { type: :string, example: 'Ticket updated successfully' },
          ticket: { type: :object }
        }

        let(:ticket) { { priority: 'high' } }

        run_test!
      end

      response '422', 'Invalid status transition' do
        schema type: :object, properties: {
          errors: { type: :array, items: { type: :string } }
        }

        let(:ticket) { { status: 'closed' } }

        run_test!
      end
    end

    delete 'Delete a ticket' do
      tags 'Tickets'
      produces 'application/json'

      response '200', 'Ticket deleted' do
        schema type: :object, properties: {
          message: { type: :string, example: 'Ticket deleted successfully' }
        }

        run_test!
      end
    end
  end

  path '/api/version1/tickets/{ticket_id}/assign' do
    parameter name: :ticket_id, in: :path, type: :string, description: 'Ticket ID'
    parameter name: :Authorization, in: :header, type: :string, required: true

    let(:existing_ticket) do
      Ticket.create!(
        title: 'Assign Test',
        description: 'Description',
        requestor: user.email,
        status: 'open',
        priority: 'low',
        source: 'email'
      )
    end
    let(:ticket_id) { existing_ticket.ticket_id }

    patch 'Assign ticket to user' do
      tags 'Tickets'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :assignment, in: :body, schema: {
        type: :object,
        properties: {
          assign_to: { type: :string, description: 'User email or "none" to unassign' }
        },
        required: %w[assign_to]
      }

      response '200', 'Ticket assigned' do
        schema type: :object, properties: {
          message: { type: :string },
          ticket: { type: :string }
        }

        let(:assignment) { { assign_to: agent.email } }

        run_test!
      end

      response '404', 'User not found' do
        schema type: :object, properties: {
          error: { type: :string }
        }

        let(:assignment) { { assign_to: 'nonexistent@example.com' } }

        run_test!
      end
    end
  end
end
