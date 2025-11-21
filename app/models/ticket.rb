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
    

    # Scopes for dashboard summary
    scope :overdue, -> { where("created_at < ?", Date.today).where.not(status: "closed") }
    scope :due_today, -> { where(created_at: Date.today.all_day) }
    scope :open_tickets, -> { where(status: ["open", "in_progress"]) }
    scope :unassigned, -> { where(user_name: [nil, ""]) }

    private

    def generate_ticket_id
      self.ticket_id=SecureRandom.hex(4)
    end

    
end
