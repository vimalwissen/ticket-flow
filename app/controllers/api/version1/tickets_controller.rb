module Api
  module Version1
    class TicketsController < ApplicationController
      before_action :authenticate_request
      before_action :set_ticket, only: [ :show, :update, :destroy, :assign ]

      # RBAC
      # Only Admin + Agent can create, update, assign, or change status
      before_action -> { authorize_role("admin", "agent") }, only: [ :create, :update, :assign ]

      # Only Admin can delete
      before_action -> { authorize_role("admin") }, only: [ :destroy ]

      # All authenticated users (including consumers) can view tickets (index/show)
      before_action :require_login, only: [ :index, :show ]


    # GET /tickets
    def index
    case current_user.role
    when "admin"
        tickets_scope = Ticket.all
    when "agent"
        tickets_scope = Ticket.where(
        "requestor = :username OR assign_to = :user_id",
        username: current_user.email,
        user_id: current_user.email
        )
    else # Consumer
        tickets_scope = Ticket.where(assign_to: current_user.email)
    end

    @q = tickets_scope.ransack(params[:q])
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

        # Check if assigned user exists **before saving**
        if ticket.assign_to.present?
            assigned_user = User.find_by(email: ticket.assign_to)

            unless assigned_user
            return render json: { error: "User '#{ticket.assign_to}' not found" }, status: :not_found
            end
        end

        # Now save the ticket only if validations passed
        if ticket.save
            SlaAssignmentService.apply(ticket)
            NotificationService.ticket_assigned(ticket, ticket.assign_to) if ticket.assign_to.present?
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


        # PUT /tickets/:ticket_id (Admin + Agent)
        def update
        new_status = ticket_params[:status]

        # If status is being updated, validate role permissions
        if new_status.present?
            case current_user.role
            when "admin"
            permitted = true
            when "agent"
            if @ticket.status == "resolved" && new_status == "open"
                return render json: {
                error: "Agents cannot reopen a resolved ticket. Only admins can do this."
                }, status: :forbidden
            end
            permitted = true
            else
            return render json: {
                error: "Only Admins or Agents can update the ticket status."
            }, status: :forbidden
            end
        end
        @ticket.updated_by_role = current_user.role

        if @ticket.update(ticket_params)
            SlaAssignmentService.apply(@ticket) if ticket_params[:priority].present?
            NotificationService.ticket_status_changed(@ticket) if new_status.present?

            render json: {
            message: "Ticket updated successfully",
            ticket: @ticket
            }, status: :ok
        else
            render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
        end



        # PATCH /tickets/:ticket_id/assign (Admin + Agent)
        def assign
            assign_value = params[:assign_to] == "none" ? nil : params[:assign_to]

            # Normalize assignment value
            if assign_value.present?
                user = User.find_by(id: assign_value) || User.find_by(email: assign_value)

                unless user
                return render json: { error: "User '#{assign_value}' not found" }, status: :not_found
                end

                assign_value = user.email
            end

            if @ticket.assign_to == assign_value
                return render json: {
                message: assign_value.present? ?
                    "Ticket is already assigned to #{assign_value}" :
                    "Ticket is already unassigned"
                }, status: :ok
            end
            if @ticket.update(assign_to: assign_value)
                NotificationService.ticket_assigned(@ticket, assign_value) if assign_value.present?

                render json: {
                message: assign_value.present? ?
                    "Ticket assigned successfully" :
                    "Ticket unassigned successfully",
                ticket: @ticket.ticket_id
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
          nil
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
        (params[:ticket] || params).permit(:title, :description, :priority, :source, :requestor, :assign_to, :status)
      end
    end
  end
end
