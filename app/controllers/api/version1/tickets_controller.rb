module Api
  module Version1
    class TicketsController < ApplicationController
      before_action :authenticate_request
      before_action :set_ticket, only: [:show, :update, :change_status, :destroy, :assign]

      # RBAC
      # Only Admin + Agent can create, update, assign, or change status
      before_action -> { authorize_role("admin", "agent") }, only: [:create, :update, :assign, :change_status]

      # Only Admin can delete
      before_action -> { authorize_role("admin") }, only: [:destroy]

      # All authenticated users (including consumers) can view tickets (index/show)
      before_action :require_login, only: [:index, :show]


      # GET /tickets
      def index
        @q = Ticket.ransack(params[:q])
        tickets = @q.result(distinct: true).order(created_at: :desc).page(params[:page]).per(params[:per_page])

        render json: {
          message: "Tickets fetched successfully",
          tickets: tickets,
          meta: {
            current_page: tickets.current_page,
            next_page: tickets.next_page,
            prev_page: tickets.prev_page,
            total_pages: tickets.total_pages,
            total_count: tickets.total_count
          }
        }, status: :ok
      end


      
      # POST /tickets (Admin + Agent only)
      def create
        ticket = Ticket.new(ticket_params)

        if ticket.save
            if ticket.assign_to.present?
                NotificationService.ticket_assigned(ticket, ticket.assign_to)
            end
          render json: {
            message: "Ticket created successfully",
            ticket: ticket
          }, status: :created
        else
          render json: { errors: ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end



      # GET /tickets/:ticket_id
      def show
        render json: {
          message: "Ticket fetched successfully",
          ticket: @ticket
        }, status: :ok
      end


      # PATCH /tickets/:ticket_id (Admin + Agent)
      def update
        if @ticket.update(ticket_params)
          render json: { message: "Ticket updated successfully", ticket: @ticket }, status: :ok
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end


      
      # PATCH /tickets/:ticket_id/status
       def change_status
        new_status = params[:status]
        @ticket.updated_by_role = current_user.role

        begin
            @ticket.change_status_to!(new_status)
            NotificationService.ticket_status_changed(@ticket)
            render json: { message: "Status updated successfully", ticket: @ticket }, status: :ok
        rescue => e
            render json: { error: e.message }, status: :unprocessable_entity
        end
        end


        
    # PATCH /tickets/:ticket_id/assign (Admin + Agent)
    def assign
    assign_value = params[:assign_to] == "none" ? nil : params[:assign_to]

    if assign_value.present?
        user = User.find_by(id: assign_value) || User.find_by(name: assign_value)

        unless user
        return render json: { error: "User '#{assign_value}' not found" }, status: :not_found
        end

        assign_value = user.id
    end

    if @ticket.update(assign_to: assign_value)
        # Only send notification **if a valid user was assigned**
      #  NotificationService.ticket_assigned(@ticket, assign_value) if assign_value.present?

        render json: { 
        message: assign_value.present? ? "Ticket assigned successfully" : "Ticket unassigned successfully",
        ticket: @ticket.ticket_id,
        assigned_user: @ticket.assigned_user&.name 
        }, status: :ok
    else
        render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
    end

      
      # DELETE /tickets/:ticket_id (Admin only)
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
        (params[:ticket] || params).permit(:title, :description, :priority, :source, :requestor, :assign_to)
      end
    end
 end
end