class ApplicationController < ActionController::API
  # Ensure CORS headers for every request
  before_action :set_cors_headers

  # Skip authentication ONLY for preflight OPTIONS request
  before_action :authenticate_request, except: [:options_request]

  attr_reader :current_user

  # Handle OPTIONS requests (CORS preflight)
  def options_request
    head :ok
  end

  private

  # -------------------------
  # CORS HEADERS
  # -------------------------
  def set_cors_headers
    response.set_header('Access-Control-Allow-Origin', '*')
    response.set_header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD')
    response.set_header('Access-Control-Allow-Headers', 'Origin, Content-Type, Authorization, Accept')
  end

  # -------------------------
  # JWT AUTHENTICATION
  # -------------------------
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