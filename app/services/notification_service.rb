class NotificationService
  def self.create(user:, message:, notifiable: nil)
    Notification.create!(
      user: user,
      message: message,
      notifiable: notifiable
    )
  end

  def self.mark_read(notification)
    notification.update!(read_at: Time.current)
  end

  def self.mark_all_read(user)
    user.notifications.unread.update_all(read_at: Time.current)
  end

  def self.recent_for(user, limit: 50)
    user.notifications.order(created_at: :desc).limit(limit)
  end

  # === Event Hooks ===

  def self.ticket_assigned(ticket, agent)
    create(
      user: User.find_by(email: agent),
      message: "You were assigned Ticket ##{ticket.ticket_id}",
      notifiable: ticket
    )
  end

  def self.ticket_status_changed(ticket)
    debugger
    return unless ticket.assign_to.present?

    user = User.find_by(email: ticket.assign_to)
    return unless user

    create(
      user: user,
      message: "Status updated for Ticket ##{ticket.ticket_id}: #{ticket.status}",
      notifiable: ticket
    )
  end
end
