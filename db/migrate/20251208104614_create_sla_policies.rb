class CreateSlaPolicies < ActiveRecord::Migration[8.1]
  def change
    create_table :sla_policies do |t|
      t.string :priority, null: false
      t.integer :first_response_minutes
      t.integer :resolution_minutes
      t.boolean :active, default: true

      t.timestamps
    end
    add_index :sla_policies, :priority, unique: true
  end
end
