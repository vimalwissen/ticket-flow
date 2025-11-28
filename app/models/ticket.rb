class Ticket < ApplicationRecord
  validates :description, :title, :requestor, presence: true
  after_initialize :set_defaults, if: :new_record?

  VALID_STATUSES = %w[open in_progress resolved]
  VALID_PRIORITIES = %w[low medium high]

  before_create :generate_ticket_id

  after_commit :run_workflows, on: [:create, :update]

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

  def run_workflows
    event_name = if previous_changes.key?('id') || saved_change_to_id?
      'ticket.created'
    else
      'ticket.updated'
    end

    ::WorkflowExecutor.new(event: event_name, subject: self, context: { changes: previous_changes }).run
  rescue => e
    Rails.logger.error("Workflow execution failed for Ticket #{id}: #{e.message}")
  end
end