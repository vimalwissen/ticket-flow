module Api
  module Version1
    class UsersController < ApplicationController
      #before_action -> { authorize_role("admin") }

      # GET /api/version1/users
      def index
        users = User.select(:id, :name, :email, :role, :created_at)
        render json: users
      end

      # POST /api/version1/users
      def create
        user = User.new(user_create_params)
        if user.save
          render json: { id: user.id, name: user.name, email: user.email, role: user.role }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/version1/users/:id
      def update
        user = User.find_by(id: params[:id])
        return render json: { error: "Not Found" }, status: :not_found unless user

        if user.update(user_update_params)
          render json: { id: user.id, name: user.name, email: user.email, role: user.role }
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_create_params
        params.permit(:name, :email, :password, :password_confirmation, :role)
      end

      # Only allow editing name and role per requirements
      def user_update_params
        params.permit(:name, :role)
      end
    end
  end
end
