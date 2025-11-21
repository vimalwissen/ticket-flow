class ApplicationController < ActionController::API
  before_action :authenticate_request
  attr_reader :current_user
  private
  def authenticate_request
    header = request.headers["Authorization"]
    if header.blank?
      return render json: { error: "Missing token" }, status: :unauthorized
    end
    token = header.split(" ").last
    decoded = JsonWebToken.decode(token)
    unless decoded && (@current_user = User.find_by(id: decoded[:user_id]))
      return render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
  # ROLE GUARD
  def authorize_role(*roles)
    unless roles.include?(current_user.role)
      render json: { error: "Forbidden" }, status: :forbidden
    end
  end
end