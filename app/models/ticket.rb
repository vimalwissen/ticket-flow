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
    

    # Scopes for dashboard summary
    scope :overdue, -> { where("created_at < ?", Date.today).where.not(status: "closed") }
    scope :due_today, -> { where(created_at: Date.today.all_day) }
    scope :open_tickets, -> { where(status: ["open", "in_progress"]) }
    scope :unassigned, -> { where(user_name: [nil, ""]) }

    # Priority distribution for charts
    scope :priority_split, -> { group(:priority).count }

    # Status distribution
    scope :status_distribution, -> { group(:status).count }

    # New tickets count for last 30 days (trend chart)
    scope :new_last_30_days, -> {
        where(created_at: 30.days.ago..Time.now)
        .group_by_day(:created_at)
        .count
    }

    
end
