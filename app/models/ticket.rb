class Ticket < ApplicationRecord
    has_many :comments, dependent: :destroy
  validates :description, :title, :requestor, presence: true
  after_initialize :set_defaults, if: :new_record?

  VALID_STATUSES = %w[open InProgress OnHold resolved]
  VALID_PRIORITIES = %w[low medium high]

  before_create :generate_ticket_id

  validates :status, inclusion: {
    in: VALID_STATUSES,
    message: "is invalid. Allowed values: #{VALID_STATUSES.join(', ')}"
  }

  validates :priority, inclusion: {
    in: VALID_PRIORITIES,
    message: "is invalid. Allowed values: #{VALID_PRIORITIES.join(', ')}"
  }

  private

  def generate_ticket_id
    self.ticket_id = SecureRandom.hex(4)
  end
  def set_defaults
    self.status ||= "open"
    self.source ||= "email"
  end
end