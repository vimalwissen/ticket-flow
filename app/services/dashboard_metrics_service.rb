class DashboardMetricsService
  def self.call(user)
    new(user).build
  end

  def initialize(user)
    @user = user
    @tickets_scope = tickets_visible_to_user
  end

  def build
    [
      { id: 1, title: "Overdue Tickets",      count: overdue,      isAlert: overdue > 0 },
      { id: 2, title: "Tickets Due Today",    count: due_today,    isAlert: false },
      { id: 3, title: "Open Tickets",         count: open_tickets, isAlert: false },
      { id: 4, title: "Tickets On Hold",      count: on_hold,      isAlert: false },
      { id: 5, title: "Unassigned Tickets",   count: unassigned,   isAlert: unassigned > 0 },
      { id: 6, title: "Tickets I'm Watching", count: watching,     isAlert: false }
    ]
  end

  private


  def tickets_visible_to_user
    case @user.role
    when "admin"
      Ticket.all

    when "agent"
      Ticket.where(
        "requestor = :email OR assign_to = :email",
        email: @user.email
      )

    else # Consumer
      Ticket.where(requestor: @user.email)
    end
  end


  def overdue
    @tickets_scope
      .where("target_resolution_at < ?", Date.today)
      .where.not(status: "closed")
      .count
  end

  def due_today
    @tickets_scope.where(target_resolution_at: Date.today.all_day).count
  end

  def open_tickets
    @tickets_scope.where(status: [ "open", "in_progress" ]).count
  end

  def unassigned
    @tickets_scope.where(assign_to: [ nil, "" ]).count
  end

  def on_hold
    @tickets_scope.where(status: "on_hold").count
  end

  def watching
    TicketWatcher.where(watcher_id: @user.id).count
  end
end
