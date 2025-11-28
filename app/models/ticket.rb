class Ticket < ApplicationRecord
    has_many :comments, dependent: :destroy
  validates :description, :title, :requestor, presence: true
  after_initialize :set_defaults, if: :new_record?
  has_one_attached :attachment

  validate :attachment_size_limit
  validate :attachment_type_validation

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

  def attachment_size_limit
    return unless attachment.attached?
    if attachment.blob.byte_size > 50.megabytes
      errors.add(:attachment, "must be less than 50MB")
      attachment.purge
    end
  end

  def attachment_type_validation
    return unless attachment.attached?
    allowed_types = ["application/pdf",
                     "application/msword",
                     "application/vnd.openxmlformats-officedocument.wordprocessingml.document"]

    unless allowed_types.include?(attachment.content_type)
      errors.add(:attachment, "must be a PDF or DOC/DOCX file")
      attachment.purge
    end
  end
end