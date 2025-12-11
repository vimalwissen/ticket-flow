class DashboardChartsService
  def self.call
    new.build
  end

  def build
    [
      priority_chart,
      status_chart,
      new_open_chart
    ]
  end

  private

  # -----------------------
  # Priority chart
  # -----------------------
  def priority_chart
    {
      id: "priority",
      type: "pie",
      title: "Unresolved Tickets by Priority",
      data: priority_split.map do |priority, count|
        {
          label: priority.to_s.humanize,
          value: count,
          color: priority_color(priority)
        }
      end
    }
  end

  def priority_split
    Ticket.group(:priority).count
  end

  # -----------------------
  # Status chart
  # -----------------------
  def status_chart
    {
      id: "status",
      type: "pie",
      title: "Unresolved Tickets by Status",
      data: status_split.map do |status, count|
        {
          label: status.to_s.humanize,
          value: count,
          color: priority_color(status)
        }
      end
    }
  end

  def status_split
    Ticket.group(:status).count
  end

  # -----------------------
  # Open tickets bar chart
  # -----------------------
  def new_open_chart
    {
      id: "open",
      type: "bar",
      title: "New & My Open Tickets",
      data: priority_split.map do |priority, count|
        {
          label: priority.to_s.humanize,
          value: count,
          color: priority_color(priority)
        }
      end
    }
  end

  # -----------------------
  # Helper for priority colors
  # -----------------------
  def priority_color(priority)
    {
      "high" => "#8b5cf6",
      "medium" => "#f59e0b",
      "low" => "#3b82f6",
      "urgent" => "#ef4444"
    }[priority] || "#999999"
  end
end
