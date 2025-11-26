class TicketWatcher < ApplicationRecord
  belongs_to :ticket,primary_key: :ticket_id, foreign_key: :ticket_id

  validates :watcher_id, presence: true
  validates :watcher_id, uniqueness: { scope: :ticket_id, message: "already watching this ticket" }
end
