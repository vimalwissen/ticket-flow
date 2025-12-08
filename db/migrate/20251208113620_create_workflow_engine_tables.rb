class CreateWorkflowEngineTables < ActiveRecord::Migration[7.0]
  def up
    # Drop in reverse dependency order to avoid FK violations
    drop_table :workflow_executions, if_exists: true, force: :cascade
    drop_table :workflow_nodes, if_exists: true, force: :cascade
    drop_table :workflow_events, if_exists: true, force: :cascade
    drop_table :workflows, if_exists: true, force: :cascade

    create_table :workflows do |t|
      t.string :name, null: false
      t.text :description
      t.integer :status, default: 2, comment: "1: active, 2: draft"
      t.integer :module_id, comment: "1: used for Tickets"
      t.integer :workspace_id
      t.jsonb :additional_config, default: {}
      t.timestamps
    end

    create_table :workflow_events do |t|
      t.references :workflow, null: false, foreign_key: true
      t.string :label
      t.string :event_type
      t.jsonb :flow, default: {}, comment: "Adjacency map for execution flow"
      t.timestamps
    end

    create_table :workflow_nodes do |t|
      t.references :workflow_event, null: false, foreign_key: true
      t.integer :wf_node_id, null: false, comment: "Logical ID (e.g., 20001)"
      t.string :label
      t.string :node_type, comment: "Derived from range (e.g. action, condition)"
      t.jsonb :data, default: {}, null: false, comment: "Node configuration"
      t.timestamps
    end

    create_table :workflow_executions do |t|
      t.references :workflow, null: false, foreign_key: true
      t.references :workflow_event, null: false, foreign_key: true
      t.references :ticket, null: false, foreign_key: true
      t.string :status, default: 'pending', null: false
      t.jsonb :context, default: {}, null: false
      t.integer :current_wf_node_id, comment: "Pointer to current logical step"
      t.jsonb :logs, default: [], array: true
      t.timestamps
    end

    add_index :workflow_executions, [:ticket_id, :status]
    add_index :workflow_nodes, [:workflow_event_id, :wf_node_id], unique: true
  end

  def down
    drop_table :workflow_executions, if_exists: true
    drop_table :workflow_nodes, if_exists: true
    drop_table :workflow_events, if_exists: true
    drop_table :workflows, if_exists: true
  end
end
