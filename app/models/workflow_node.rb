class WorkflowNode < ApplicationRecord
  belongs_to :workflow_event

  validates :wf_node_id, presence: true
  validates :node_type, presence: true

  # Constants for Type Ranges
  EVENT_RANGE       = 1..10000
  CONDITION_RANGE   = 10001..20000
  ACTION_RANGE      = 20001..30000
  READER_RANGE      = 30001..40000
  ORCHESTRATION_RANGE = 40001..50000

  def type_from_range
    case wf_node_id
    when EVENT_RANGE then :event
    when CONDITION_RANGE then :condition
    when ACTION_RANGE then :action
    when READER_RANGE then :reader
    when ORCHESTRATION_RANGE then :orchestration
    else :unknown
    end
  end

  before_validation :set_derived_type

  private

  def set_derived_type
    self.node_type = type_from_range.to_s
  end
end
