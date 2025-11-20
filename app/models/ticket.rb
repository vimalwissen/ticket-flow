class Ticket < ApplicationRecord
    validates :ticket_id, :description , presence: true
     enum :status, {
    open: "open",
    in_progress: "in_progress",
    resolved: "resolved",
    closed: "closed"
  }
    
end
