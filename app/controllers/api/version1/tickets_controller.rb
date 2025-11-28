module Api
  module Version1
    class TicketsController < ApplicationController
      before_action :authenticate_request
      before_action :set_ticket, only: [:show, :update, :change_status, :destroy, :assign]

      # ---- RBAC ----
      # Only Admin + Agent can create, update, assign, or change status
      before_action -> { authorize_role("admin", "agent") }, only: [:create, :update, :assign, :change_status]

      # Only Admin can delete
      before_action -> { authorize_role("admin") }, only: [:destroy]

      # All authenticated users (including consumers) can view tickets (index/show)
      before_action :require_login, only: [:index, :show]


      # =========================
      # GET /tickets
      # =========================
      def index
        tickets = Ticket.all.order(created_at: :desc)

        render json: {
          message: "Tickets fetched successfully",
          tickets: tickets
        }, status: :ok
      end


      # =========================
      # POST /tickets (Admin + Agent only)
      # =========================
      def create
        ticket = Ticket.new(ticket_params)

        if ticket.save
          render json: {
            message: "Ticket created successfully",
            ticket: ticket
          }, status: :created
        else
          render json: { errors: ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end


      # =========================
      # GET /tickets/:ticket_id
      # =========================
      def show
        render json: {
          message: "Ticket fetched successfully",
          ticket: @ticket
        }, status: :ok
      end


      # =========================
      # PATCH /tickets/:ticket_id (Admin + Agent)
      # =========================
      def update
        if @ticket.update(ticket_params)
          render json: { message: "Ticket updated successfully", ticket: @ticket }, status: :ok
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end


      # =========================
      # PATCH /tickets/:ticket_id/status (Admin + Agent)
      # =========================
      def change_status
        if @ticket.update(status: params[:status])
          render json: { message: "Status updated successfully", ticket: @ticket }, status: :ok
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end


      # =========================
      # PATCH /tickets/:ticket_id/assign (Admin + Agent)
      # =========================
      def assign
        assign_value = params[:assign_to] == "none" ? nil : params[:assign_to]

        if @ticket.update(assign_to: assign_value)
          render json: { message: "Ticket assigned successfully", ticket: @ticket }, status: :ok
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end


      # =========================
      # DELETE /tickets/:ticket_id (Admin only)
      # =========================
      def destroy
        @ticket.destroy
        render json: { message: "Ticket deleted successfully" }, status: :ok
      end


      private

     def require_login
        return if current_user.present?
        render json: { error: "Unauthorized" }, status: :unauthorized
      end


      def authorize_role(*allowed_roles)
        unless allowed_roles.include?(current_user.role)
          render json: {
            error: "Access Denied: Required role(s): #{allowed_roles.join(', ')}"
          }, status: :forbidden
          return
        end
      end

      def unauthorized_response
        render json: { error: "Unauthorized" }, status: :unauthorized
      end

      def set_ticket
        @ticket = Ticket.find_by(ticket_id: params[:ticket_id])
        render json: { error: "Ticket not found" }, status: :not_found unless @ticket
      end

      def ticket_params
        params.permit(:title, :description, :status, :source, :priority, :requestor, :assign_to)
      end
    end
 end
end