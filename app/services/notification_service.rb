class NotificationService
  def self.mark_read(notification)
    notification.update!(read_at: Time.current)
  end

  def self.mark_all_read(user)
    user.notifications.unread.update_all(read_at: Time.current)
  end

  def self.recent_for(user, limit: 50)
    user.notifications.order(created_at: :desc).limit(limit)
  end

  def self.ticket_event(ticket:, actor:, message:)
    recipients = User.where(role: "admin").to_a

    recipients << User.find_by(email: ticket.assign_to) if ticket.assign_to.present?
    recipients << User.find_by(email: ticket.requestor)

    recipients = recipients.compact.uniq - [ actor ]

    recipients.each do |user|
      Notification.create!(
        user: user,
        message: message,
        notifiable: ticket
      )
    end
  end
end
