class InitDb < ActiveRecord::Migration[7.0]
  def change
    create_table "channels", force: :cascade do |t|
      t.bigint "user_id", null: false
      t.string "channel_id"
      t.string "access_token"
      t.string "refresh_token"
      t.datetime "token_expires_at"
      t.boolean "is_token_expired", default: false
      t.jsonb "additional_info", default: {}
      t.jsonb "settings", default: {}
      t.jsonb "counts", default: {}
      t.integer "status", default: 0
      t.string "manual_job_id"
      t.string "inventory_sync_job_id"
      t.string "order_sync_job_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["user_id"], name: "index_channels_on_user_id"
    end

    create_table "events", force: :cascade do |t|
      t.bigint "channel_id", null: false
      t.integer "sync_record_id"
      t.integer "event_type", null: false
      t.string "summary"
      t.jsonb "data", default: {}
      t.boolean "has_error", default: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["channel_id"], name: "index_events_on_channel_id"
      t.index ["event_type"], name: "index_events_on_event_type"
    end

    create_table "sync_matches", force: :cascade do |t|
      t.bigint "channel_id", null: false
      t.jsonb "categories", default: [], null: false
      t.jsonb "products", default: [], null: false
      t.jsonb "variants", default: [], null: false
      t.jsonb "inventory", default: [], null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["channel_id"], name: "index_sync_matches_on_channel_id"
    end

    create_table "sync_operations", force: :cascade do |t|
      t.bigint "sync_record_id", null: false
      t.integer "action", null: false
      t.string "item_id"
      t.string "match_id"
      t.string "parent_id"
      t.string "name"
      t.integer "item_type"
      t.integer "original_type"
      t.string "error_message"
      t.integer "provider"
      t.integer "step"
      t.jsonb "data", default: {}
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["sync_record_id", "action"], name: "index_sync_operations_on_sync_record_id_and_action"
      t.index ["sync_record_id"], name: "index_sync_operations_on_sync_record_id"
    end

    create_table "sync_records", force: :cascade do |t|
      t.bigint "channel_id", null: false
      t.string "job_id"
      t.integer "sync_mode"
      t.integer "status", default: 0
      t.integer "progress", default: 0
      t.string "progress_text"
      t.boolean "has_error", default: false
      t.jsonb "change_count", default: {}, null: false
      t.jsonb "stats", default: {}, null: false
      t.datetime "last_successful_run"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["channel_id"], name: "index_sync_records_on_channel_id"
    end

    create_table "users", force: :cascade do |t|
      t.string "store_hash", null: false
      t.string "email", null: false
      t.string "username"
      t.string "access_token"
      t.string "uid"
      t.integer "store_id"
      t.string "scope"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["store_hash", "email"], name: "index_users_on_store_hash_and_email", unique: true
      t.index ["store_hash"], name: "index_users_on_store_hash"
    end

    add_foreign_key "channels", "users"
    add_foreign_key "events", "channels"
    add_foreign_key "sync_matches", "channels"
    add_foreign_key "sync_operations", "sync_records", on_delete: :cascade
    add_foreign_key "sync_records", "channels"
  end
end
