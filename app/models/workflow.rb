class Workflow < ApplicationRecord
  has_many :events, class_name: 'WorkflowEvent', dependent: :destroy
  has_many :executions, class_name: 'WorkflowExecution', dependent: :destroy

  accepts_nested_attributes_for :events, allow_destroy: true

  validates :name, presence: true
  
  # Scopes
  scope :active, -> { where(status: 1) }

  def active?
    status == 1
  end
end
