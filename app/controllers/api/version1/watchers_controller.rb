module Api
  module Version1
    class WatchersController < ApplicationController
      before_action :authenticate_request
      before_action :set_ticket

      # POST /api/version1/tickets/watch
      def create
        result = WatcherService.add(ticket: @ticket, user: current_user)

        if result[:success]
          render json: result, status: :created
        else
          render json: result, status: :unprocessable_entity
        end
      end

      # DELETE /api/version1/tickets/watch
      def destroy
        result = WatcherService.remove(ticket: @ticket, user: current_user)
        render json: result, status: :ok
      end

      private

      def set_ticket
        @ticket = Ticket.find_by(ticket_id: params[:ticket_id])
        render json: { error: "Ticket not found" }, status: :not_found unless @ticket
      end
    end
  end
end
