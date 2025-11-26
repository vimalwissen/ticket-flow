require "test_helper"

class Api::Version1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @agent = users(:agent_user)
    @agent_token = JsonWebToken.encode(user_id: @agent.id)
  end

  test "should not get index as agent" do
    get api_version1_users_url, headers: { Authorization: "Bearer #{@agent_token}" }
    assert_response :forbidden
  end
end
