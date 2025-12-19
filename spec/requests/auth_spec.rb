require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  path '/auth/login' do
    post 'User login' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'user@example.com' },
          password: { type: :string, example: 'password123' }
        },
        required: %w[email password]
      }

      let(:user) { User.find_or_create_by!(email: 'login@example.com', name: 'Login User') { |u| u.password = 'password123' } }

      response '200', 'Login successful' do
        schema type: :object, properties: {
          access_token: { type: :string, description: 'JWT access token' },
          refresh_token: { type: :string, description: 'Refresh token for getting new access tokens' },
          role: { type: :string, example: 'admin', description: 'User role' }
        }

        let(:credentials) { { email: user.email, password: 'password123' } }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body['access_token']).to be_present
          expect(body['refresh_token']).to be_present
        end
      end

      response '401', 'Invalid credentials' do
        schema type: :object, properties: {
          error: { type: :string, example: 'Invalid email or password' }
        }

        let(:credentials) { { email: 'wrong@example.com', password: 'wrong' } }

        run_test!
      end
    end
  end

  path '/auth/refresh' do
    post 'Refresh access token' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :token, in: :body, schema: {
        type: :object,
        properties: {
          refresh_token: { type: :string, description: 'Valid refresh token' }
        },
        required: %w[refresh_token]
      }

      response '200', 'Token refreshed' do
        schema type: :object, properties: {
          access_token: { type: :string },
          refresh_token: { type: :string }
        }

        let(:refresh_user) do
          User.find_or_create_by!(email: 'refresh@example.com', name: 'Refresh User') { |u| u.password = 'password' }
        end

        before do
          refresh_user.update!(refresh_token: 'valid_refresh_token_123')
        end

        let(:token) { { refresh_token: 'valid_refresh_token_123' } }

        run_test!
      end

      response '401', 'Invalid refresh token' do
        schema type: :object, properties: {
          error: { type: :string, example: 'Invalid refresh token' }
        }

        let(:token) { { refresh_token: 'invalid_token' } }

        run_test!
      end
    end
  end

  path '/auth/logout' do
    post 'User logout' do
      tags 'Authentication'
      produces 'application/json'
      parameter name: :Authorization, in: :header, type: :string, required: true

      let(:user) { User.find_or_create_by!(email: 'logout@example.com', name: 'Logout User') { |u| u.password = 'password' } }
      let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }

      response '200', 'Logged out successfully' do
        schema type: :object, properties: {
          message: { type: :string, example: 'Logged out' }
        }

        run_test!
      end
    end
  end
end
