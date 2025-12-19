class ApplicationController < ActionController::API
  # CORS headers for every request
  before_action :set_cors_headers
 
  # Skip authentication for preflight OPTIONS requests
  before_action :authenticate_request, except: [:options_request]
 
  attr_reader :current_user
 
  # Handle OPTIONS preflight requests
  def options_request
    head :ok
  end

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
 
  private

  def not_found(e)
    render json: { error: e.message }, status: :not_found
  end

  def unprocessable_entity(e)
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end
 
  # -------------------------
  # CORS HEADERS
  # -------------------------
  def set_cors_headers
    response.set_header('Access-Control-Allow-Origin', '*')
    response.set_header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD')
    response.set_header('Access-Control-Allow-Headers', 'Origin, Content-Type, Authorization, Accept')
  end
 
  # -------------------------
  # JWT AUTH
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
 
  # -------------------------
  # ROLE-BASED ACCESS CONTROL
  # -------------------------
  def authorize_role(*allowed_roles)
    unless allowed_roles.include?(current_user.role)
      render json: { error: "Forbidden" }, status: :forbidden
      return
    end
  end
end