module Api
    module Version1
        class TicketsController < ApplicationController
            before_action :set_ticket, only: [:show, :update, :destroy]

            # GET /tickets
            def index
            tickets = Ticket.all
            render json: tickets
            end

            # POST /tickets
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
            :source, :priority, :user_name)
            end

        end
    end
end