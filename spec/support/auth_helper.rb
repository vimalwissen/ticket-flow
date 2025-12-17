module AuthHelper
  def auth_headers(user = nil)
    user ||= User.create!(email: "test-#{SecureRandom.hex(4)}@example.com", name: 'Test', password: 'password')
    token = JsonWebToken.encode(user_id: user.id)
    { 'Authorization' => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
