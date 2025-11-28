module Api
  module Version1
    class TicketsController < ApplicationController
      # ============================
      # RBAC RULES
      # ============================
 
      # ADMIN: full access (list all, delete)
      before_action -> { authorize_role("admin") }, only: [:index, :destroy]
 
      # ADMIN + AGENT: can create, view single ticket, assign
      before_action -> { authorize_role("admin", "agent") }, only: [:create, :show, :assign]
 
    #   # CONSUMER: cannot update or change status (admin only)
      before_action :restrict_consumer_update, only: [:update, :change_status]
 
      # Ticket lookup
      before_action :set_ticket, only: [:show, :update, :change_status, :destroy, :assign]
 
 
      # ============================
      # GET /tickets  (Admin only)
      # ============================
      def index
        tickets = Ticket.all
        render json: tickets
      end
 
 
      # ============================
      # POST /tickets
      # ============================
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
 
 
      # ============================
      # GET /tickets/:ticket_id
      # ============================
      def show
        render json: {
          message: "Ticket fetched successfully",
          ticket: @ticket
        }, status: :ok
      end
 
 
      # ============================
      # PATCH /tickets/:ticket_id
      # ============================
      def update
        if @ticket.update(ticket_params)
          render json: {
            message: "Ticket updated successfully",
            ticket: @ticket
          }, status: :ok
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end
 
 
      # ============================
      # PATCH /tickets/:ticket_id/status
      # ============================
      def change_status
        if @ticket.update(status: params[:status])
          render json: { message: "Status updated", ticket: @ticket }
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end
 
 
      # ============================
      # PATCH /tickets/:ticket_id/assign
      # ============================
      def assign
        username_value = (params[:assign_to] == "none" ? nil : params[:assign_to])
 
        if @ticket.update(assign_to: username_value)
          render json: {
            message: "Ticket assigned successfully",
            ticket: @ticket
          }, status: :ok
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end
 
 
      # ============================
      # DELETE /tickets/:ticket_id (Admin only)
      # ============================
      def destroy
        @ticket.destroy
        render json: { message: "Ticket deleted" }
      end
 
 
      private
 
      # ============================
      # Consumer restriction logic
      # ============================
      def restrict_consumer_update
        if current_user.role == "consumer"
          render json: { error: "Comsumer cannot update or change status" }, status: :forbidden
          return
        end
      end
 
      # ============================
      # Ticket loader
      # ============================
      def set_ticket
        @ticket = Ticket.find_by(ticket_id: params[:ticket_id])
        unless @ticket
          render_not_found
          return
        end
      end
 
      # Strong params
      def ticket_params
        params.permit(:title, :description, :status, :source, :priority, :requestor, :assign_to)
      end
 
      # Error helper
      def render_not_found
        render json: { error: "Ticket not found" }, status: :not_found
      end
 
    end
  end
end