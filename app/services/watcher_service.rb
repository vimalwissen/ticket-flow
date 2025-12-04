class WatcherService
  def self.add(ticket:, user:)
    watcher = TicketWatcher.find_or_initialize_by(
      ticket_id: ticket.ticket_id,
      watcher_id: user.id
    )

    return {
      success: true,
      message: "Already watching this ticket",
      watcher: watcher
    } if watcher.persisted?

    if watcher.save
      {
        success: true,
        message: "Started watching ticket",
        watcher: watcher
      }
    else
      {
        success: false,
        errors: watcher.errors.full_messages
      }
    end
  end

  def self.remove(ticket:, user:)
    watcher = TicketWatcher.find_by(
      ticket_id: ticket.ticket_id,
      watcher_id: user.id
    )

    return {
      success: true,
      message: "You were not watching this ticket"
    } unless watcher

    watcher.destroy

    {
      success: true,
      message: "Stopped watching this ticket"
    }
  end
end
