class Workflow < ApplicationRecord
  validates :name, presence: true
  validates :event, presence: true

  scope :active, -> { where(active: true) }

  # conditions and actions are stored as JSONB. We expect the following shape:
  # conditions: { "all": [ { "field": "assigned_to_id", "operator": "present" }, ... ] }
  # actions: [ { "type": "update", "field": "status", "value": "approved" }, ... ]

  def conditions_all
    (conditions || {})["all"] || []
  end

  def actions_array
    actions.is_a?(Array) ? actions : (actions || [])
  end
end
