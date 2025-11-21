class AuthController < ApplicationController
  skip_before_action :authenticate_request, only: [:login, :refresh]
  # POST /auth/login
  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      access  = JsonWebToken.encode({ user_id: user.id, role: user.role })
      refresh = SecureRandom.hex(32)
      user.update(refresh_token: refresh)
      render json: {
        access_token: access,
        refresh_token: refresh,
        role: user.role
      }
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end
  # POST /auth/refresh
  def refresh
    user = User.find_by(refresh_token: params[:refresh_token])
    unless user
      return render json: { error: "Invalid refresh token" }, status: :unauthorized
    end
    access = JsonWebToken.encode({ user_id: user.id, role: user.role })
    refresh = SecureRandom.hex(32)
    user.update(refresh_token: refresh)
    render json: {
      access_token: access,
      refresh_token: refresh
    }
  end
  # POST /auth/logout
  def logout
    current_user.update(refresh_token: nil)
    render json: { message: "Logged out" }
  end
end