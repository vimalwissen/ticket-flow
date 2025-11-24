require "test_helper"

class Api::Version1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    @agent = users(:agent_user)
    @admin_token = JsonWebToken.encode(user_id: @admin.id)
    @agent_token = JsonWebToken.encode(user_id: @agent.id)
  end

  test "should get index as admin" do
    get api_version1_users_url, headers: { Authorization: "Bearer #{@admin_token}" }
    assert_response :success
  end

  test "should not get index as agent" do
    get api_version1_users_url, headers: { Authorization: "Bearer #{@agent_token}" }
    assert_response :forbidden
  end

  test "should create user as admin" do
    user_params = { user: { name: "New User", email: "new@example.com", password: "pass123", password_confirmation: "pass123", role: "agent" } }
    post api_version1_users_url, params: user_params, headers: { Authorization: "Bearer #{@admin_token}" }
    assert_response :created
    json = JSON.parse(response.body)
    assert_equal json['email'], 'new@example.com'
  end

  test "should update user name and role as admin" do
    patch api_version1_user_url(@agent), params: { user: { name: "Updated", role: "consumer" } }, headers: { Authorization: "Bearer #{@admin_token}" }
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal json['name'], 'Updated'
    assert_equal json['role'], 'consumer'
  end
end
