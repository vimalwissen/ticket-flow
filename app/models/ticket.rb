class Ticket < ApplicationRecord
  has_many :comments, dependent: :destroy
  has_one_attached :attachment , dependent: :purge_later

  attr_accessor :updated_by_role
  belongs_to :assigned_user, class_name: "User", foreign_key: "assign_to", optional: true

  validates :description, :title, :requestor, presence: true
  validates :title, length: { maximum: 100, message: "cannot exceed 100 characters" }
  validates :description, length: { maximum: 5000, message: "cannot exceed 5000 characters" }
  validates :requestor, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :assign_to, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }, allow_blank: true
  validate :validate_assign_to_user
  validate :validate_requestor_user

  before_validation :normalize_status_value
  after_initialize :set_defaults, if: :new_record?

  # --- Attachment Validations (SAFE: no purge here) ---
  validate :attachment_size_limit
  validate :attachment_type_validation

  before_create :generate_ticket_id
  
  after_create_commit :trigger_workflow_created
  after_update_commit :trigger_workflow_updated

  def trigger_workflow_created
    # Using a service to decouple logic
    Workflow::TriggerService.call("ticket_created", self)
  end

  def trigger_workflow_updated
    Workflow::TriggerService.call("ticket_updated", self)
  end

  # -------------------------------
  # STATUS CONSTANTS (merged)
  # -------------------------------
  STATUSES = %w[open in_progress on_hold resolved closed].freeze
  SOURCE   = %w[email phone chat web].freeze

  TRANSITIONS = {
    "open"         => %w[in_progress on_hold resolved],
    "in_progress"  => %w[on_hold resolved],
    "on_hold"      => %w[in_progress resolved],
    "resolved"     => %w[closed open],  # open allowed only by admin
    "closed"       => []
  }.freeze

  validates :status, inclusion: { in: STATUSES, message: "must be one of: #{STATUSES.join(', ')}" }
  validates :source, inclusion: { in: SOURCE, message: "must be one of: #{SOURCE.join(', ')}" }

  PRIORITIES = %w[low medium high].freeze
  validates :priority, inclusion: { in: PRIORITIES, message: "must be one of: #{PRIORITIES.join(', ')}" }

  validate :validate_status_transition

  # ===============================
  #       STATUS LOGIC
  # ===============================
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
    return if new_record?

    previous = Ticket.normalize_status(status_was)
    new_val  = Ticket.normalize_status(status)

    return if previous == new_val

    allowed = TRANSITIONS[previous] || []

    # ADMIN OVERRIDE
    if previous == "resolved" && new_val == "open"
      return if updated_by_role == "admin"
    end

    if previous == "closed" && new_val == "open"
      return if updated_by_role == "admin"
    end

    unless allowed.include?(new_val)
      errors.add(:status, "cannot transition from '#{previous}' to '#{new_val}'. Allowed: #{allowed.join(', ')}")
    end
  end

  # ===============================
  #      PRIVATE HELPERS
  # ===============================
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
    errors.add(:requestor, "must be a valid registered user email") unless User.exists?(email: requestor)
  end

  # --------------------------
  # Attachment Validations
  # --------------------------
  MAX_ATTACHMENT_BYTES = 10.megabytes
  ALLOWED_CONTENT_TYPES = %w[
    application/pdf
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    image/jpeg
    image/png
    image/gif
    image/webp
  ].freeze

  def attachment_size_limit
    return unless attachment.attached?

    byte_size = attachment.blob&.byte_size
    if byte_size.nil?
      errors.add(:attachment, "could not read file size")
      return
    end

    if byte_size > MAX_ATTACHMENT_BYTES
      errors.add(:attachment, "file size must be less than #{MAX_ATTACHMENT_BYTES / 1.megabyte} MB")
    end
  end

  def attachment_type_validation
    return unless attachment.attached?

    content_type = attachment.blob&.content_type

    if content_type.nil?
      errors.add(:attachment, "could not detect content type")
      return
    end

    unless ALLOWED_CONTENT_TYPES.include?(content_type)
      errors.add(:attachment, "must be PDF, DOC, DOCX, or image (JPEG, PNG, GIF, WEBP) format")
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      assign_to created_at description id priority requestor source
      status ticket_id title updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    ["comments"]
  end
end
