module Api
  module Version1
    class TicketFormOptionsController < ApplicationController
      # GET /ticket_form_options
      def index
        render json: {
          status: {
            open: "Open",
            in_progress: "In Progress",
            resolved: "Resolved",
            on_hold: "On Hold",
            closed: "Closed"
          },
          priority: [
            { label: "Low", value: "low" },
            { label: "Medium", value: "medium" },
            { label: "High", value: "high" }
          ],
          source: [
            { label: "Email", value: "email" },
            { label: "Phone", value: "phone" },
            { label: "Web", value: "web" },
            { label: "Chat", value: "chat" }
          ],
          status_transitions: {
            admin: {
              open: [ "in_progress", "on_hold", "resolved" ],
              in_progress: [ "resolved", "on_hold" ],
              on_hold: [ "in_progress", "resolved" ],
              resolved: [ "open", "closed" ],
              closed: [ "open" ]
            },
            agent: {
              open: [ "in_progress", "on_hold", "resolved" ],
              in_progress: [ "resolved", "on_hold" ],
              on_hold: [ "in_progress", "resolved" ],
              resolved: [ "closed" ]
            }
          }
        }, status: :ok
      end
    end
  end
end
