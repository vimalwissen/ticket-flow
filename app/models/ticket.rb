class Ticket < ApplicationRecord
    validates  :description , presence: true
    before_create :generate_ticket_id
    enum :status, {
    open: "open",
    in_progress: "in_progress",
    resolved: "resolved"
  }
    enum :priority, {
        low: "low",
        medium: "medium",
        high: "high"
    }

           
        private

        def generate_ticket_id
          self.ticket_id=SecureRandom.hex(4)
        end

end
