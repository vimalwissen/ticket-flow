class DashboardMetricsService
  def self.call
    new.build
  end

  def build
    [
      { id: 1, title: "Overdue Tickets",      count: overdue,      isAlert: overdue > 0 },
      { id: 2, title: "Tickets Due Today",    count: due_today,    isAlert: false },
      { id: 3, title: "Open tickets",         count: open_tickets, isAlert: false },
      { id: 4, title: "Tickets On Hold",      count: on_hold,      isAlert: false },
      { id: 5, title: "Unassigned Tickets",   count: unassigned,   isAlert: unassigned > 0 },
      { id: 6, title: "Tickets I'm Watching", count: watching,     isAlert: false }
    ]
  end

  private

  def overdue
    Ticket.where("created_at < ?", Date.today)
          .where.not(status: "closed")
          .count
  end

  def due_today
    Ticket.where(created_at: Date.today.all_day).count
  end

  def open_tickets
    Ticket.where(status: ["open", "in_progress"]).count
  end

  def unassigned
    Ticket.where(requestor: [nil, ""]).count
  end

  def on_hold
    Ticket.where(status: "on_hold").count
  end

  def watching
    0 # To implement later
  end
end
