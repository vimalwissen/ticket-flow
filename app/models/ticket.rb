class Ticket < ApplicationRecord
    # validates :subject, :description , presence: true
    # enum status: {
    #         open: "open",
    #         in_progress: "in_progress",
    #         resolved: "resolved",
    #         closed: "closed"
    #     }

    # Scopes for dashboard summary
    scope :overdue, -> { where("created_at < ?", Date.today).where.not(status: "closed") }
    scope :due_today, -> { where(created_at: Date.today.all_day) }
    scope :open_tickets, -> { where(status: ["open", "in_progress"]) }
    scope :unassigned, -> { where(user_name: [nil, ""]) }

    
end
