# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_08_113620) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.string "author"
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "ticket_id", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_id"], name: "index_comments_on_ticket_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "message"
    t.bigint "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.datetime "read_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "sla_policies", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.integer "first_response_minutes"
    t.string "priority", null: false
    t.integer "resolution_minutes"
    t.datetime "updated_at", null: false
    t.index ["priority"], name: "index_sla_policies_on_priority", unique: true
  end

  create_table "ticket_watchers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ticket_id"
    t.datetime "updated_at", null: false
    t.integer "watcher_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "assign_to"
    t.datetime "created_at", null: false
    t.string "description"
    t.string "priority"
    t.string "requestor"
    t.integer "sla_policy_id"
    t.string "source", default: "email"
    t.string "status", default: "open"
    t.datetime "target_first_response_at"
    t.datetime "target_resolution_at"
    t.string "ticket_id"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.string "refresh_token"
    t.string "role", default: "consumer", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["refresh_token"], name: "index_users_on_refresh_token"
  end

  create_table "workflow_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_type"
    t.jsonb "flow", default: {}, comment: "Adjacency map for execution flow"
    t.string "label"
    t.datetime "updated_at", null: false
    t.bigint "workflow_id", null: false
    t.index ["workflow_id"], name: "index_workflow_events_on_workflow_id"
  end

  create_table "workflow_executions", force: :cascade do |t|
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.integer "current_wf_node_id", comment: "Pointer to current logical step"
    t.jsonb "logs", default: [], array: true
    t.string "status", default: "pending", null: false
    t.bigint "ticket_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "workflow_event_id", null: false
    t.bigint "workflow_id", null: false
    t.index ["ticket_id", "status"], name: "index_workflow_executions_on_ticket_id_and_status"
    t.index ["ticket_id"], name: "index_workflow_executions_on_ticket_id"
    t.index ["workflow_event_id"], name: "index_workflow_executions_on_workflow_event_id"
    t.index ["workflow_id"], name: "index_workflow_executions_on_workflow_id"
  end

  create_table "workflow_nodes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data", default: {}, null: false, comment: "Node configuration"
    t.string "label"
    t.string "node_type", comment: "Derived from range (e.g. action, condition)"
    t.datetime "updated_at", null: false
    t.integer "wf_node_id", null: false, comment: "Logical ID (e.g., 20001)"
    t.bigint "workflow_event_id", null: false
    t.index ["workflow_event_id", "wf_node_id"], name: "index_workflow_nodes_on_workflow_event_id_and_wf_node_id", unique: true
    t.index ["workflow_event_id"], name: "index_workflow_nodes_on_workflow_event_id"
  end

  create_table "workflows", force: :cascade do |t|
    t.jsonb "additional_config", default: {}
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "module_id", comment: "1: used for Tickets"
    t.string "name", null: false
    t.integer "status", default: 2, comment: "1: active, 2: draft"
    t.datetime "updated_at", null: false
    t.integer "workspace_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "tickets"
  add_foreign_key "notifications", "users"
  add_foreign_key "workflow_events", "workflows"
  add_foreign_key "workflow_executions", "tickets"
  add_foreign_key "workflow_executions", "workflow_events"
  add_foreign_key "workflow_executions", "workflows"
  add_foreign_key "workflow_nodes", "workflow_events"
end
