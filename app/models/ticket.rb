class Ticket < ApplicationRecord
    validates :ticket_id, :description , presence: true
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
    

end
