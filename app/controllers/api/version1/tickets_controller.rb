module Api
    module Version1
        class TicketsController < ApplicationController
            before_action :set_ticket, only: [ :show, :update, :change_status, :destroy, :assign ]

            # GET /tickets
            def index
            tickets = Ticket.all
            render json: tickets
            end

            # POST /tickets
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
            if @ticket
                render json: {
                message: "Ticket fetched successfully",
                ticket: @ticket
                }, status: :ok
            else
                render json: {
                error: "Ticket not found"
                }, status: :not_found
            end
            end

            # PATCH /tickets/:ticket_id
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

            # PATCH /tickets/:ticket_id/status
            def change_status
            if @ticket.update(status: params[:status])
                NotificationService.ticket_status_changed(@ticket)
            render json: { message: "Status updated", ticket: @ticket }
            else
            render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
            end
            end

            # PATCH /tickets/:ticket_id/assign
            def assign
            username_value = params[:assign_to] == "none" ? nil : params[:assign_to]

            if @ticket.update(assign_to: username_value)

                if username_value.present?
                    NotificationService.ticket_assigned(@ticket, username_value)
                end

                render json: {
                message: "Ticket assigned successfully",
                ticket: @ticket
                }, status: :ok
            else
                render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
            end
            end

            # DELETE /tickets/:ticket_id
            def destroy
            @ticket.destroy
            render json: { message: "Ticket deleted" }
            end

            private
            def set_ticket
            @ticket = Ticket.find_by(ticket_id: params[:ticket_id])
            render json: { error: "Ticket not found" }, status: :not_found if @ticket.nil?
            end

            def ticket_params
            params.permit(:title, :description, :status,
            :source, :priority, :requestor, :assign_to)
            end
        end
    end
end
