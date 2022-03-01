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

ActiveRecord::Schema.define(version: 2021_12_13_121624) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_function :random_uuid_bigint, sql_definition: <<-SQL
      CREATE OR REPLACE FUNCTION public.random_uuid_bigint()
       RETURNS bigint
       LANGUAGE plpgsql
       STRICT
      AS $function$
      BEGIN
      RETURN floor(random()* (9223372036854775800) + 1);
      END;
      $function$
  SQL

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_admin_comments", id: :serial, force: :cascade do |t|
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

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.bigint "box_id"
    t.bigint "user_id"
    t.bigint "family_id"
    t.string "title"
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["box_id"], name: "index_active_storage_attachments_on_box_id"
    t.index ["family_id"], name: "index_active_storage_attachments_on_family_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
    t.index ["user_id"], name: "index_active_storage_attachments_on_user_id"
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "appreciations", force: :cascade do |t|
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

  create_table "attachments", id: :serial, force: :cascade do |t|
    t.integer "media_file_id", null: false
    t.integer "containable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "containable_type", null: false
    t.integer "position"
    t.integer "comments_count"
    t.integer "box_id"
    t.bigint "uuid", default: -> { "random_uuid_bigint()" }
    t.index ["box_id"], name: "index_attachments_on_box_id"
    t.index ["containable_type", "containable_id"], name: "index_attachments_on_containable_type_and_containable_id"
    t.index ["media_file_id"], name: "index_attachments_on_media_file_id"
    t.index ["uuid"], name: "index_attachments_on_uuid"
  end

  create_table "boxes", id: :serial, force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "vault_id"
    t.integer "legacy_user_id"
    t.bigint "uuid", default: -> { "random_uuid_bigint()" }
    t.bigint "parent_box_id"
    t.index ["legacy_user_id"], name: "index_boxes_on_legacy_user_id"
    t.index ["name", "vault_id", "parent_box_id"], name: "index_boxes_on_name_and_vault_id_and_parent_box_id", unique: true
    t.index ["name", "vault_id"], name: "index_boxes_on_name_and_vault_id", unique: true, where: "(parent_box_id IS NULL)"
    t.index ["uuid"], name: "index_boxes_on_uuid"
    t.index ["vault_id"], name: "index_boxes_on_vault_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.integer "chapterable_id"
    t.string "chapterable_type"
    t.integer "position"
    t.string "title"
    t.text "body"
    t.string "media_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "author_id", null: false
    t.index ["author_id"], name: "index_chapters_on_author_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "body", null: false
    t.string "commentable_type", null: false
    t.integer "commentable_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "uuid", default: -> { "random_uuid_bigint()" }
    t.integer "comments_count", default: 0, null: false
    t.bigint "publication_id"
    t.index ["publication_id"], name: "index_comments_on_publication_id"
    t.index ["uuid"], name: "index_comments_on_uuid"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
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

  create_table "families", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "old_cover", default: "", null: false
    t.integer "cover_image_id"
    t.text "motto", default: "", null: false
    t.integer "legacy_connector_id"
    t.bigint "storage_size", default: 0
    t.bigint "uuid", default: -> { "random_uuid_bigint()" }
    t.boolean "ability_all", default: true, null: false
    t.string "family_type", default: "Community", null: false
    t.text "description"
    t.index ["legacy_connector_id"], name: "index_families_on_legacy_connector_id"
    t.index ["uuid"], name: "index_families_on_uuid"
  end

  create_table "family_subscriptions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "family_id", null: false
    t.jsonb "billing_plan_data", default: {}, null: false
    t.string "stripe_id"
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.boolean "cancel_at_period_end", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["family_id"], name: "index_family_subscriptions_on_family_id"
    t.index ["user_id"], name: "index_family_subscriptions_on_user_id"
  end

  create_table "invitations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
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
    t.string "role", default: "member", null: false
    t.integer "kinship_id"
    t.index ["family_id"], name: "index_invitations_on_family_id"
  end

  create_table "kinships", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "family_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nickname", null: false
    t.string "location"
    t.string "birth_date"
    t.string "birth_place"
    t.string "address"
    t.string "phone"
    t.string "email"
    t.string "death_date"
    t.integer "media_avatar_id"
    t.string "role", default: "guest", null: false
    t.jsonb "profile_attrs", default: {"emails"=>[{"name"=>"email", "value"=>""}], "website"=>"", "facebook"=>"", "addresses"=>[{"name"=>"address", "value"=>""}], "instagram"=>"", "locations"=>[{"name"=>"location", "value"=>""}], "birth_date"=>"", "birth_place"=>"", "phone_numbers"=>[{"name"=>"phone number", "value"=>""}]}, null: false
    t.string "description"
    t.bigint "inviter_id"
    t.index ["family_id", "role"], name: "index_kinships_on_family_id_and_role", unique: true, where: "((role)::text = 'admin'::text)"
    t.index ["inviter_id"], name: "index_kinships_on_inviter_id"
    t.index ["user_id", "family_id"], name: "index_kinships_on_user_id_and_family_id", unique: true, where: "(user_id IS NOT NULL)"
  end

  create_table "media_files", id: :serial, force: :cascade do |t|
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
    t.boolean "migrated", default: false, null: false
    t.string "migration_error"
    t.index ["type"], name: "index_media_files_on_type"
    t.index ["user_id"], name: "index_media_files_on_user_id"
  end

  create_table "ownership_transfers", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.bigint "old_admin_id", null: false
    t.bigint "new_admin_id", null: false
    t.bigint "family_id", null: false
    t.datetime "expires_at"
    t.string "status", default: "pending", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["family_id"], name: "index_ownership_transfers_on_family_id"
    t.index ["new_admin_id"], name: "index_ownership_transfers_on_new_admin_id"
    t.index ["old_admin_id"], name: "index_ownership_transfers_on_old_admin_id"
  end

  create_table "publications", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "family_id"
    t.integer "story_id", null: false
    t.date "publish_on"
    t.datetime "notified_at"
    t.string "share_type", default: "community", null: false
    t.integer "comments_count", default: 0, null: false
    t.integer "appreciations_count", default: 0, null: false
    t.integer "all_comments_count", default: 0, null: false
    t.index ["family_id"], name: "index_publications_on_family_id"
    t.index ["notified_at"], name: "index_publications_on_notified_at"
    t.index ["publish_on"], name: "index_publications_on_publish_on"
    t.index ["story_id"], name: "index_publications_on_story_id"
  end

  create_table "read_marks", id: :serial, force: :cascade do |t|
    t.string "readable_type", null: false
    t.integer "readable_id"
    t.integer "reader_id", null: false
    t.datetime "timestamp"
    t.string "reader_type"
    t.index ["reader_id", "reader_type", "readable_type", "readable_id"], name: "read_marks_reader_readable_index", unique: true
  end

  create_table "sections", id: :serial, force: :cascade do |t|
    t.text "body"
    t.integer "story_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "media_type", null: false
    t.integer "position", null: false
    t.integer "author_id", null: false
    t.string "title"
    t.boolean "aws"
    t.integer "comments_count", default: 0, null: false
    t.index ["position"], name: "index_sections_on_position"
    t.index ["story_id"], name: "index_sections_on_story_id"
  end

  create_table "stories", id: :serial, force: :cascade do |t|
    t.string "title", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "date", default: "", null: false
    t.text "description", default: "", null: false
    t.integer "user_id", null: false
    t.string "categories", default: [], array: true
    t.integer "cover_image_id"
    t.string "start_year"
    t.string "start_month"
    t.string "start_day"
    t.string "end_year"
    t.string "end_month"
    t.string "end_day"
    t.boolean "is_range", default: false
    t.string "date_as_text", default: "", null: false
    t.integer "comments_count", default: 0, null: false
    t.bigint "appreciations_count", default: 0
    t.integer "sections_count", default: 0, null: false
    t.integer "contributors_count", default: 0, null: false
    t.bigint "uuid", default: -> { "random_uuid_bigint()" }
    t.boolean "aws"
    t.integer "original_story_id"
    t.index ["updated_at"], name: "index_stories_on_updated_at"
    t.index ["user_id"], name: "index_stories_on_user_id"
    t.index ["uuid"], name: "index_stories_on_uuid"
  end

  create_table "stripe_plans", force: :cascade do |t|
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

  create_table "subscriptions", id: :serial, force: :cascade do |t|
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

  create_table "users", id: :serial, force: :cascade do |t|
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
    t.bigint "storage_size", default: 0
    t.bigint "uuid", default: -> { "random_uuid_bigint()" }
    t.boolean "ability_all", default: true, null: false
    t.index ["caretaker_id"], name: "index_users_on_caretaker_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["remember_token"], name: "index_users_on_remember_token"
    t.index ["uuid"], name: "index_users_on_uuid"
  end

  create_table "vaults", id: :serial, force: :cascade do |t|
    t.integer "legacy_user_id"
    t.integer "legacy_family_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "uuid", default: -> { "random_uuid_bigint()" }
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.index ["legacy_family_id"], name: "index_vaults_on_legacy_family_id"
    t.index ["legacy_user_id"], name: "index_vaults_on_legacy_user_id"
    t.index ["owner_type", "owner_id"], name: "index_vaults_on_owner"
    t.index ["uuid"], name: "index_vaults_on_uuid"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appreciations", "users"
  add_foreign_key "attachments", "boxes"
  add_foreign_key "boxes", "users", column: "legacy_user_id"
  add_foreign_key "boxes", "vaults"
  add_foreign_key "families", "users", column: "legacy_connector_id"
  add_foreign_key "family_subscriptions", "families"
  add_foreign_key "family_subscriptions", "users"
  add_foreign_key "media_files", "users"
  add_foreign_key "ownership_transfers", "families"
  add_foreign_key "sections", "users", column: "author_id"
  add_foreign_key "stories", "users"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "vaults", "families", column: "legacy_family_id"
  add_foreign_key "vaults", "users", column: "legacy_user_id"
end
