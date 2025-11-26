require "test_helper"

class Api::Version1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @agent = users(:agent_user)
    @agent_token = JsonWebToken.encode(user_id: @agent.id)
  end

end
