class WorkflowEvent < ApplicationRecord
  belongs_to :workflow
  has_many :nodes, class_name: 'WorkflowNode', dependent: :destroy
  has_many :executions, class_name: 'WorkflowExecution', dependent: :destroy

  accepts_nested_attributes_for :nodes, allow_destroy: true

  # Validations
  # validates :flow, presence: true

  def find_node(logical_id)
    nodes.find_by(wf_node_id: logical_id)
  end
end
