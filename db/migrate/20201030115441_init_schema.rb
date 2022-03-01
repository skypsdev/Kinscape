class InitSchema < ActiveRecord::Migration[6.0]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "hstore"
    enable_extension "plpgsql"
    enable_extension "uuid-ossp"
    create_table "action_text_rich_texts" do |t|
      t.string "name", null: false
      t.text "body"
      t.string "record_type", null: false
      t.bigint "record_id", null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
    end
    create_table "active_admin_comments", id: :serial do |t|
      t.string "namespace"
      t.text "body"
      t.string "resource_type"
      t.integer "resource_id"
      t.string "author_type"
      t.integer "author_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
      t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
      t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
    end
    create_table "active_storage_attachments" do |t|
      t.string "name", null: false
      t.string "record_type", null: false
      t.bigint "record_id", null: false
      t.bigint "blob_id", null: false
      t.datetime "created_at", null: false
      t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
      t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
    end
    create_table "active_storage_blobs" do |t|
      t.string "key", null: false
      t.string "filename", null: false
      t.string "content_type"
      t.text "metadata"
      t.bigint "byte_size", null: false
      t.string "checksum", null: false
      t.datetime "created_at", null: false
      t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
    end
    create_table "appreciations" do |t|
      t.string "appreciable_type", null: false
      t.bigint "appreciable_id", null: false
      t.bigint "user_id", null: false
      t.integer "reaction", null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["appreciable_type", "appreciable_id"], name: "index_appreciations_on_appreciable_type_and_appreciable_id"
      t.index ["user_id", "appreciable_type", "appreciable_id"], name: "index_appreciations_on_user_uniqueness", unique: true
      t.index ["user_id"], name: "index_appreciations_on_user_id"
    end
    create_table "attachments", id: :serial do |t|
      t.integer "media_file_id", null: false
      t.integer "containable_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "containable_type", null: false
      t.integer "position"
      t.integer "comments_count"
      t.integer "box_id"
      t.index ["box_id"], name: "index_attachments_on_box_id"
      t.index ["containable_type", "containable_id"], name: "index_attachments_on_containable_type_and_containable_id"
      t.index ["media_file_id"], name: "index_attachments_on_media_file_id"
    end
    create_table "attics", id: :serial do |t|
      t.integer "user_id"
      t.integer "family_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["family_id"], name: "index_attics_on_family_id"
      t.index ["user_id"], name: "index_attics_on_user_id"
    end
    create_table "boxes", id: :serial do |t|
      t.text "name", default: "", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "attic_id"
      t.integer "user_id"
      t.index ["attic_id"], name: "index_boxes_on_attic_id"
      t.index ["user_id"], name: "index_boxes_on_user_id"
    end
    create_table "chapters" do |t|
      t.integer "chapterable_id"
      t.string "chapterable_type"
      t.integer "position"
      t.string "title"
      t.text "body"
      t.string "media_type"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end
    create_table "comments", id: :serial do |t|
      t.text "body", null: false
      t.string "commentable_type", null: false
      t.integer "commentable_id", null: false
      t.integer "user_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "conversions", id: :serial do |t|
      t.integer "user_id", null: false
      t.string "process_id", null: false
      t.string "file_name", null: false
      t.string "original_filename", null: false
      t.string "state", default: "converting", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["file_name"], name: "index_conversions_on_file_name", unique: true
      t.index ["user_id"], name: "index_conversions_on_user_id"
    end
    create_table "delayed_jobs", id: :serial do |t|
      t.integer "priority", default: 0, null: false
      t.integer "attempts", default: 0, null: false
      t.text "handler", null: false
      t.text "last_error"
      t.datetime "run_at"
      t.datetime "locked_at"
      t.datetime "failed_at"
      t.string "locked_by"
      t.string "queue"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["priority", "run_at"], name: "delayed_jobs_priority"
    end
    create_table "families", id: :serial do |t|
      t.string "name", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "old_cover", default: "", null: false
      t.integer "cover_image_id"
      t.text "motto", default: "", null: false
      t.integer "connector_id"
      t.bigint "storage_size", default: 0
      t.index ["connector_id"], name: "index_families_on_connector_id"
    end
    create_table "invitations", id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "family_id", null: false
      t.integer "sender_id", null: false
      t.integer "recipient_id"
      t.string "email", null: false
      t.datetime "accepted_at"
      t.text "message", default: "", null: false
      t.string "first_name"
      t.string "last_name"
      t.index ["family_id"], name: "index_invitations_on_family_id"
    end
    create_table "kinships", id: :serial do |t|
      t.integer "user_id", null: false
      t.integer "family_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "nickname"
      t.string "location"
      t.string "birth_date"
      t.string "birth_place"
      t.string "address"
      t.string "phone"
      t.string "email"
      t.string "death_date"
      t.integer "media_avatar_id"
      t.boolean "is_invitation_accept", default: false
    end
    create_table "media_files", id: :serial do |t|
      t.string "mimetype"
      t.text "url", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.text "filename", default: "", null: false
      t.string "key", default: "", null: false
      t.string "type"
      t.integer "height"
      t.integer "width"
      t.hstore "converted_urls", default: {}
      t.integer "user_id"
      t.integer "size"
      t.string "title"
      t.index ["type"], name: "index_media_files_on_type"
      t.index ["user_id"], name: "index_media_files_on_user_id"
    end
    create_table "publications", id: :serial do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "family_id", null: false
      t.integer "story_id", null: false
      t.date "publish_on"
      t.datetime "notified_at"
      t.index ["family_id"], name: "index_publications_on_family_id"
      t.index ["notified_at"], name: "index_publications_on_notified_at"
      t.index ["publish_on"], name: "index_publications_on_publish_on"
      t.index ["story_id"], name: "index_publications_on_story_id"
    end
    create_table "read_marks", id: :serial do |t|
      t.string "readable_type", null: false
      t.integer "readable_id"
      t.integer "reader_id", null: false
      t.datetime "timestamp"
      t.string "reader_type"
      t.index ["reader_id", "reader_type", "readable_type", "readable_id"], name: "read_marks_reader_readable_index", unique: true
    end
    create_table "sections", id: :serial do |t|
      t.text "body"
      t.integer "story_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "media_type", null: false
      t.integer "position", null: false
      t.integer "author_id"
      t.string "title"
      t.index ["position"], name: "index_sections_on_position"
      t.index ["story_id"], name: "index_sections_on_story_id"
    end
    create_table "stories", id: :serial do |t|
      t.string "title", default: "", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "date", default: "", null: false
      t.text "description", default: "", null: false
      t.integer "user_id", null: false
      t.string "tags", default: [], array: true
      t.integer "cover_image_id"
      t.string "start_year"
      t.string "start_month"
      t.string "start_day"
      t.string "end_year"
      t.string "end_month"
      t.string "end_day"
      t.boolean "is_range", default: false
      t.string "date_as_text", default: "", null: false
      t.integer "comments_count"
      t.bigint "appreciations_count", default: 0
      t.index ["updated_at"], name: "index_stories_on_updated_at"
      t.index ["user_id"], name: "index_stories_on_user_id"
    end
    create_table "stripe_plans" do |t|
      t.string "plan_id"
      t.boolean "active"
      t.string "nickname"
      t.string "currency"
      t.integer "amount"
      t.string "interval"
      t.integer "trial_period_days"
      t.string "product"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end
    create_table "subscriptions", id: :serial do |t|
      t.integer "user_id", null: false
      t.text "billing_plan_data", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "status"
      t.string "stripe_id"
      t.datetime "trial_end"
      t.datetime "trial_start"
      t.datetime "current_period_start"
      t.datetime "current_period_end"
      t.boolean "cancel_at_period_end"
      t.index ["status"], name: "index_subscriptions_on_status"
      t.index ["user_id"], name: "index_subscriptions_on_user_id"
    end
    create_table "table_of_chapters" do |t|
      t.text "links", default: [], array: true
      t.integer "table_of_chapterable_id"
      t.string "table_of_chapterable_type"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end
    create_table "table_of_contents", id: :serial do |t|
      t.integer "story_id"
      t.text "links", default: [], array: true
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["story_id"], name: "index_table_of_contents_on_story_id"
    end
    create_table "users", id: :serial do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "email", null: false
      t.string "encrypted_password", limit: 128, null: false
      t.string "confirmation_token", limit: 128
      t.string "remember_token", limit: 128, null: false
      t.string "old_avatar", default: "", null: false
      t.hstore "metadata"
      t.boolean "tour_completed"
      t.string "first_name"
      t.string "last_name"
      t.integer "avatar_id"
      t.integer "caretaker_id"
      t.string "title"
      t.datetime "confirmed_at"
      t.boolean "admin", default: false
      t.string "stripe_id"
      t.integer "selected_family_id"
      t.bigint "storage_size", default: 0
      t.index ["caretaker_id"], name: "index_users_on_caretaker_id"
      t.index ["email"], name: "index_users_on_email"
      t.index ["remember_token"], name: "index_users_on_remember_token"
    end
    add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
    add_foreign_key "appreciations", "users"
    add_foreign_key "attachments", "boxes"
    add_foreign_key "attics", "families"
    add_foreign_key "attics", "users"
    add_foreign_key "boxes", "attics"
    add_foreign_key "boxes", "users"
    add_foreign_key "families", "users", column: "connector_id"
    add_foreign_key "media_files", "users"
    add_foreign_key "subscriptions", "users"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
