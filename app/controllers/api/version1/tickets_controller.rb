module Api
  module Version1
    class TicketsController < ApplicationController
      
      before_action :set_ticket, only: [:show, :update, :change_status, :destroy, :assign]

      # RBAC Rules
      before_action -> { authorize_role("admin") }, only: [:destroy]
      before_action -> { authorize_role("admin", "agent") }, only: [:create, :update, :assign, :change_status]

      # Allow all authenticated roles to view tickets and show
      before_action :require_login, only: [:index, :show]


      # GET /tickets (ADMIN, AGENT, CONSUMER)
      def index
        tickets = case current_user.role
                  when "admin"
                    Ticket.all.order(created_at: :desc)
                  when "agent"
                    Ticket.where(assign_to: current_user.id)
                          .or(Ticket.where(requestor: current_user.id))
                          .order(created_at: :desc)
                  when "consumer"
                    Ticket.all.order(created_at: :desc)
                    #Ticket.where(requestor: current_user.id).order(created_at: :desc)
                  end

        render json: {
          message: "Tickets fetched successfully",
          count: tickets.count,
          tickets: tickets
        }, status: :ok
      end


      # POST /tickets
      def create
        ticket = Ticket.new(ticket_params.merge(requestor: current_user.id))

        if ticket.save
          render json: { message: "Ticket created successfully", ticket: ticket }, status: :created
        else
          render json: { errors: ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end


      # GET /tickets/:ticket_id
      def show
        if current_user.admin? || current_user.id == @ticket.requestor || current_user.id == @ticket.assign_to
          render json: { message: "Ticket fetched successfully", ticket: @ticket }, status: :ok
        else
          render json: { error: "Access denied" }, status: :forbidden
        end
      end


      def update
        if @ticket.update(ticket_params)
          render json: { message: "Ticket updated successfully", ticket: @ticket }, status: :ok
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end


      def change_status
        if @ticket.update(status: params[:status])
          render json: { message: "Status updated successfully", ticket: @ticket }, status: :ok
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end


      def assign
        assign_value = params[:assign_to] == "none" ? nil : params[:assign_to]

        if @ticket.update(assign_to: assign_value)
          render json: { message: "Ticket assigned successfully", ticket: @ticket }, status: :ok
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end


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


      def set_ticket
        @ticket = Ticket.find_by(ticket_id: params[:ticket_id])
        return if @ticket.present?

        render json: { error: "Ticket not found" }, status: :not_found
      end


      def ticket_params
        params.permit(:title, :description, :status, :source, :priority, :assign_to)
      end
    end
  end
end
