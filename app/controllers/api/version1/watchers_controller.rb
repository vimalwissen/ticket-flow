module Api
  module Version1
    class WatchersController < ApplicationController
      before_action :set_ticket
    
       #GET /api/version1/tickets/:ticket_id/watchers
       def index
        watchers = TicketWatcher.where(ticket_id: @ticket.ticket_id)

        render json: {
          message: "Watcher fetched successfully",
          ticket_id: @ticket.ticket_id,
          total_watchers: watchers.count,
          watchers: watchers
        }, status: :ok
      end

      # POST /api/version1/tickets/:ticket_id/watchers
      def create
        watcher_id = params[:watcher_id]

        if watcher_id.blank?
          return render json: { error: "watcher_id is required" }, status: :unprocessable_entity
        end

        watcher = TicketWatcher.find_or_initialize_by(
          ticket_id: @ticket.ticket_id,
          watcher_id: watcher_id
        )

        if watcher.persisted?
          return render json: { message: "Watcher already exists" }, status: :ok
        end

        if watcher.save
          render json: { message: "Watcher added successfully", watcher: watcher }, status: :created
        else
          render json: { errors: watcher.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/version1/tickets/:ticket_id/watchers/:watcher_id
      def destroy
        watcher = TicketWatcher.find_by(
          ticket_id: @ticket.ticket_id,
          watcher_id: params[:watcher_id]
        )

        unless watcher
          return render json: { error: "Watcher not found" }, status: :not_found
        end

        watcher.destroy
        render json: { message: "Watcher removed successfully" }, status: :ok
      end

      private

      def set_ticket
        @ticket = Ticket.find_by(ticket_id: params[:ticket_id])
        unless @ticket
          render json: { error: "Ticket not found" }, status: :not_found
        end
      end
    end
  end
end
