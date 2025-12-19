class WorkflowExecution < ApplicationRecord
  belongs_to :workflow
  belongs_to :workflow_event
  belongs_to :ticket

  validates :status, presence: true
end
