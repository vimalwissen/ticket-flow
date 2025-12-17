class AddSlaTargetsToTickets < ActiveRecord::Migration[8.1]
  def change
    add_column :tickets, :target_first_response_at, :datetime
    add_column :tickets, :target_resolution_at, :datetime
    add_column :tickets, :sla_policy_id, :integer
  end
end
