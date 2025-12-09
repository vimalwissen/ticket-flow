class Ticket < ApplicationRecord
  has_many :comments, dependent: :destroy
  has_one_attached :attachment
  attr_accessor :updated_by_role
  belongs_to :assigned_user, class_name: "User", foreign_key: "assign_to", optional: true

  validates :description, :title, :requestor, presence: true
  validate :validate_assign_to_user
  validate :validate_requestor_user 

  before_validation :normalize_status_value
  after_initialize :set_defaults, if: :new_record?
  has_one_attached :attachment

  validate :attachment_size_limit
  validate :attachment_type_validation


  before_create :generate_ticket_id
  # Final allowed statuses
  STATUSES = %w[open in_progress on_hold resolved].freeze
  SOURCE=%w[email phone chat web].freeze

  # Allowed transitions
  TRANSITIONS = {
    "open" => %w[in_progress on_hold resolved],
    "in_progress" => %w[on_hold resolved],
    "on_hold" => %w[in_progress resolved],
    "resolved" => [] 
  }.freeze

  validates :status, inclusion: {
    in: STATUSES,
    message: "must be one of: #{STATUSES.join(', ')}"
  }
  validates :source, inclusion: {
    in: SOURCE,
    message: "must be one of: #{SOURCE.join(', ')}"
  }

  # Priority validation
  PRIORITIES = %w[low medium high].freeze
  validates :priority, inclusion: {
    in: PRIORITIES,
    message: "must be one of: #{PRIORITIES.join(', ')}"
  }

  validate :validate_status_transition

  def change_status_to!(raw_new_status)
    assign_attributes(status: Ticket.normalize_status(raw_new_status))
    
    unless valid?
      raise ArgumentError, errors.full_messages.join(", ")
    end

    save!
  end
  def can_transition_to?(raw_new_status)
    normalized_new = Ticket.normalize_status(raw_new_status)
    normalized_current = Ticket.normalize_status(self.status)

    allowed = TRANSITIONS[normalized_current] || []
    allowed.include?(normalized_new)
  end

  def self.normalize_status(value)
    return nil if value.nil?
    
    value = value.to_s.strip.downcase.gsub(/\s+/, "_")
    value.gsub!("inprogress", "in_progress")
    value.gsub!("onhold", "on_hold")

    value
  end

  def validate_status_transition
    return if new_record? # allow on create

    normalized_previous = Ticket.normalize_status(status_was)
    normalized_new = Ticket.normalize_status(status)

    # Allow updates that do NOT modify the status
    return if normalized_previous == normalized_new

    allowed = TRANSITIONS[normalized_previous] || []

    # ---- ADMIN OVERRIDE CASE ----
    if normalized_previous == "resolved" && normalized_new == "open"
      return if updated_by_role == "admin"
    end

    unless allowed.include?(normalized_new)
      errors.add(:status, "cannot transition from '#{normalized_previous}' to '#{normalized_new}'. Allowed: #{allowed.join(', ')}")
  end
end

  private

  def normalize_status_value
    self.status = Ticket.normalize_status(status)
  end

  def generate_ticket_id
    self.ticket_id = SecureRandom.hex(4)
  end

  def set_defaults
    return unless new_record?

    self.status ||= "open"
    self.source ||= "email"
  end

  def validate_assign_to_user
    return if assign_to.blank?
    errors.add(:assign_to, "must belong to a registered user") unless User.exists?(email: assign_to)
  end

  def validate_requestor_user
    return if requestor.blank?
    unless User.exists?(email: requestor)
      errors.add(:requestor, "must be a valid registered user email")
    end
  end

  # Attachment validations
  def attachment_size_limit
    return unless attachment.attached?    
    if attachment.blob.byte_size > 50.megabytes
      errors.add(:attachment, "must be less than 50MB")
      attachment.purge
    end
  end

  def attachment_type_validation
    return unless attachment.attached?

    allowed_types = %w[
      application/pdf
      application/msword
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
    ]

    unless allowed_types.include?(attachment.content_type)
      errors.add(:attachment, "must be PDF or DOC/DOCX")
      attachment.purge
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["assign_to", "created_at", "description", "id", "priority", "requestor", "source", "status", "ticket_id", "title", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["comments"]
  end
end