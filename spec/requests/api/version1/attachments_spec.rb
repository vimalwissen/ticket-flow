require 'swagger_helper'

RSpec.describe 'Attachments API', type: :request do
  let(:user) { User.find_or_create_by!(email: 'test@example.com', name: 'Test') { |u| u.password = 'password' } }
  let(:agent) { User.find_or_create_by!(email: 'agent@example.com', name: 'Agent') { |u| u.password = 'password' } }
  let(:auth_user) { User.find_or_create_by!(email: 'admin@example.com', name: 'Admin') { |u| u.password = 'password' } }
  let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: auth_user.id)}" }

  let(:ticket) do
    Ticket.create!(
      title: 'Test Ticket',
      description: 'Test description',
      requestor: user.email,
      assign_to: agent.email,
      status: 'open',
      priority: 'low',
      source: 'email'
    )
  end
  let(:ticket_id) { ticket.ticket_id }

  path '/api/version1/tickets/{ticket_id}/attachment' do
    parameter name: :ticket_id, in: :path, type: :string, description: 'Ticket ID'
    parameter name: :Authorization, in: :header, type: :string, required: true

    post 'Upload attachment' do
      tags 'Attachments'
      consumes 'multipart/form-data'
      produces 'application/json'
      parameter name: :attachment, in: :formData, type: :file, required: true, description: 'File to upload (PDF, DOC, DOCX, or images)'

      response '201', 'Attachment uploaded successfully' do
        schema type: :object, properties: {
          message: { type: :string, example: 'Attachment uploaded successfully' }
        }

        let(:attachment) do
          Rack::Test::UploadedFile.new(
            StringIO.new('%PDF-1.4 test'),
            'application/pdf',
            original_filename: 'test.pdf'
          )
        end

        run_test!
      end

      response '400', 'Attachment missing' do
        schema type: :object, properties: {
          error: { type: :string, example: 'Attachment missing' }
        }

        let(:attachment) { nil }

        run_test! do
          post "/api/version1/tickets/#{ticket_id}/attachment", headers: { 'Authorization' => Authorization }
        end
      end

      response '409', 'Attachment already exists' do
        schema type: :object, properties: {
          error: { type: :string, example: 'Attachment already exists. Please delete the existing attachment first.' }
        }

        before do
          ticket.attachment.attach(io: StringIO.new('existing'), filename: 'existing.pdf', content_type: 'application/pdf')
          ticket.save!
        end

        let(:attachment) do
          Rack::Test::UploadedFile.new(
            StringIO.new('%PDF-1.4 new'),
            'application/pdf',
            original_filename: 'new.pdf'
          )
        end

        run_test!
      end

      response '422', 'Invalid file type' do
        schema type: :object, properties: {
          errors: { type: :array, items: { type: :string } }
        }

        let(:attachment) do
          Rack::Test::UploadedFile.new(
            StringIO.new('exe content'),
            'application/x-msdownload',
            original_filename: 'test.exe'
          )
        end

        run_test!
      end
    end

    get 'Get attachment metadata' do
      tags 'Attachments'
      produces 'application/json'

      response '200', 'Attachment metadata' do
        schema type: :object, properties: {
          filename: { type: :string, example: 'document.pdf' },
          content_type: { type: :string, example: 'application/pdf' },
          byte_size: { type: :integer, example: 12345 },
          created_at: { type: :string, format: 'date-time' }
        }

        before do
          ticket.attachment.attach(io: StringIO.new('content'), filename: 'doc.pdf', content_type: 'application/pdf')
          ticket.save!
        end

        run_test!
      end

      response '200', 'No attachment found' do
        schema type: :object, properties: {
          message: { type: :string, example: 'No attachment found for this ticket' }
        }

        run_test!
      end
    end

    delete 'Delete attachment' do
      tags 'Attachments'
      produces 'application/json'

      response '200', 'Attachment deleted' do
        schema type: :object, properties: {
          message: { type: :string, example: 'Attachment removed successfully' }
        }

        before do
          ticket.attachment.attach(io: StringIO.new('to delete'), filename: 'delete.pdf', content_type: 'application/pdf')
          ticket.save!
        end

        run_test!
      end

      response '404', 'No attachment to remove' do
        schema type: :object, properties: {
          error: { type: :string, example: 'No attachment to remove' }
        }

        run_test!
      end
    end
  end

  path '/api/version1/tickets/{ticket_id}/attachment/download' do
    parameter name: :ticket_id, in: :path, type: :string, description: 'Ticket ID'
    parameter name: :Authorization, in: :header, type: :string, required: true

    get 'Download attachment file' do
      tags 'Attachments'
      produces 'application/octet-stream'

      response '200', 'File download' do
        before do
          ticket.attachment.attach(io: StringIO.new('file content'), filename: 'download.pdf', content_type: 'application/pdf')
          ticket.save!
        end

        run_test! do |response|
          expect(response.headers['Content-Disposition']).to include('download.pdf')
        end
      end

      response '404', 'No attachment found' do
        schema type: :object, properties: {
          error: { type: :string, example: 'No attachment found for this ticket' }
        }

        run_test!
      end
    end
  end
end
