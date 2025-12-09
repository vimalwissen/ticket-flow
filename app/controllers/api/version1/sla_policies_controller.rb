module Api
  module Version1
    class SlaPoliciesController < ApplicationController
      before_action :authenticate_request
      before_action -> { authorize_role("admin") }
      before_action :set_policy, only: [ :show, :update, :destroy ]

      # GET /api/version1/sla_policies
      def index
        policies = SlaPolicy.all.order(:priority)
        render json: { policies: policies }, status: :ok
      end

      # GET /api/version1/sla_policies/:id
      def show
        render json: { policy: @policy }, status: :ok
      end

      # POST /api/version1/sla_policies
      def create
        policy = SlaPolicy.new(policy_params)
        if policy.save
          render json: { message: "SLA Policy created", policy: policy }, status: :created
        else
          render json: { errors: policy.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/version1/sla_policies/:id
      def update
        if @policy.update(policy_params)
          render json: { message: "SLA Policy updated", policy: @policy }, status: :ok
        else
          render json: { errors: @policy.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/version1/sla_policies/:id
      def destroy
        @policy.destroy
        render json: { message: "SLA Policy deleted" }, status: :ok
      end

      private

      def set_policy
        @policy = SlaPolicy.find_by(id: params[:id])
        render json: { error: "SLA Policy not found" }, status: :not_found unless @policy
      end

      def policy_params
        params.require(:sla_policy).permit(
          :priority,
          :first_response_minutes,
          :resolution_minutes,
          :active
        )
      end
    end
  end
end
