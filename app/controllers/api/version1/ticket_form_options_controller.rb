module Api
  module Version1
    class TicketFormOptionsController < ApplicationController
      # GET /ticket_form_options
      def index
        render json: {
          status: [
            { label: 'Open', value: 'open' },
            { label: 'In Progress', value: 'in_progress' },
            { label: 'Resolved', value: 'resolved' },
            { label: 'On Hold', value: 'on_hold' }
          ],
          priority: [
            { label: 'Low', value: 'low' },
            { label: 'Medium', value: 'medium' },
            { label: 'High', value: 'high' }
          ],
          source: [
            { label: 'Email', value: 'email' },
            { label: 'Phone', value: 'phone' },
            { label: 'Web', value: 'web' },
            { label: 'Chat', value: 'chat' }
          ]
        }, status: :ok
      end
    end
  end
end
