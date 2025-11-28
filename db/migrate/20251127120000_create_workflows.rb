class CreateWorkflows < ActiveRecord::Migration[6.1]
  def change
    create_table :workflows do |t|
      t.string :name, null: false
      t.string :event, null: false
      t.jsonb :conditions, null: false, default: {}
      t.jsonb :actions, null: false, default: {}
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :workflows, :event
    add_index :workflows, :active
  end
end
