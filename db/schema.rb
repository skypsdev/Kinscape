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

ActiveRecord::Schema.define(version: 2022_02_18_150944) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "action_text_rich_texts", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.bigint "integer_id"
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_integer_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "record_id", null: false
    t.index ["record_id", "record_type", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
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
    t.bigint "integer_record_id"
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.bigint "integer_box_id"
    t.bigint "integer_user_id"
    t.bigint "integer_family_id"
    t.string "title"
    t.integer "copy_number", default: 0, null: false
    t.uuid "family_id"
    t.uuid "record_id", null: false
    t.uuid "user_id"
    t.uuid "box_id"
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["box_id"], name: "index_active_storage_attachments_on_box_id"
    t.index ["family_id"], name: "index_active_storage_attachments_on_family_id"
    t.index ["record_type", "record_id", "name", "blob_id", "copy_number", "box_id"], name: "index_active_storage_attachments_uniqueness_with_box", unique: true, where: "(box_id IS NOT NULL)"
    t.index ["record_type", "record_id", "name", "blob_id", "copy_number"], name: "index_active_storage_attachments_uniqueness", unique: true, where: "(box_id IS NULL)"
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

  create_table "active_storage_variant_records", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.bigint "integer_id"
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
    t.index ["blob_id"], name: "index_active_storage_variant_records_on_blob_id"
  end

  create_table "appreciations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.bigint "integer_id"
    t.string "appreciable_type", null: false
    t.bigint "appreciable_integer_id"
    t.bigint "integer_user_id"
    t.integer "reaction", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "appreciable_id", null: false
    t.uuid "user_id", null: false
    t.index ["appreciable_id", "appreciable_type"], name: "index_appreciations_on_appreciable_id_and_appreciable_type"
    t.index ["created_at"], name: "index_appreciations_on_created_at"
    t.index ["user_id", "appreciable_id", "appreciable_type"], name: "index_appreciation_user_uniqueness", unique: true
    t.index ["user_id"], name: "index_appreciations_on_user_id"
  end

  create_table "boxes", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "integer_id"
    t.string "name", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "integer_vault_id"
    t.bigint "integer_parent_box_id"
    t.uuid "vault_id", null: false
    t.uuid "parent_box_id"
    t.index ["created_at"], name: "index_boxes_on_created_at"
    t.index ["name", "vault_id", "parent_box_id"], name: "index_boxes_on_name_and_vault_id_and_parent_box_id", unique: true
    t.index ["name", "vault_id"], name: "index_boxes_on_name_and_vault_id", unique: true, where: "(parent_box_id IS NULL)"
    t.index ["parent_box_id"], name: "index_boxes_on_parent_box_id"
    t.index ["vault_id"], name: "index_boxes_on_vault_id"
  end

  create_table "chapters", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.bigint "integer_id"
    t.integer "integer_chapterable_id"
    t.string "chapterable_type"
    t.integer "position"
    t.string "title"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "integer_author_id"
    t.integer "appreciations_count", default: 0, null: false
    t.bigint "integer_kinship_id"
    t.boolean "showcase", default: false, null: false
    t.uuid "kinship_id"
    t.uuid "chapterable_id", null: false
    t.uuid "author_id", null: false
    t.integer "comments_count", default: 0, null: false
    t.index ["author_id"], name: "index_chapters_on_author_id"
    t.index ["chapterable_id", "chapterable_type"], name: "index_chapters_on_chapterable_id_and_chapterable_type"
    t.index ["created_at"], name: "index_chapters_on_created_at"
    t.index ["kinship_id"], name: "index_chapters_on_kinship_id"
  end

  create_table "comments", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "integer_id"
    t.text "body", null: false
    t.string "commentable_type", null: false
    t.integer "integer_commentable_id"
    t.integer "integer_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comments_count", default: 0, null: false
    t.bigint "integer_publication_id"
    t.uuid "commentable_id", null: false
    t.uuid "user_id", null: false
    t.uuid "top_commentable_id", null: false
    t.string "top_commentable_type", null: false
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type"
    t.index ["created_at"], name: "index_comments_on_created_at"
    t.index ["user_id"], name: "index_comments_on_user_id"
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

  create_table "families", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "integer_id"
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "motto", default: "", null: false
    t.boolean "ability_all", default: true, null: false
    t.string "family_type", default: "Community", null: false
    t.text "description"
    t.string "access_type", default: "default", null: false
    t.boolean "showcase", default: false, null: false
    t.index ["created_at"], name: "index_families_on_created_at"
  end

  create_table "family_subscriptions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.bigint "integer_user_id"
    t.bigint "integer_family_id"
    t.jsonb "billing_plan_data", default: {}, null: false
    t.string "stripe_id"
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.boolean "cancel_at_period_end", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "family_id", null: false
    t.uuid "user_id", null: false
    t.index ["created_at"], name: "index_family_subscriptions_on_created_at"
    t.index ["family_id"], name: "index_family_subscriptions_on_family_id"
    t.index ["user_id"], name: "index_family_subscriptions_on_user_id"
  end

  create_table "invitations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "integer_family_id"
    t.integer "integer_sender_id"
    t.integer "integer_recipient_id"
    t.string "email", null: false
    t.datetime "accepted_at"
    t.text "message", default: "", null: false
    t.string "role", default: "member", null: false
    t.integer "integer_kinship_id"
    t.boolean "showcase", default: false, null: false
    t.uuid "family_id", null: false
    t.uuid "kinship_id"
    t.uuid "sender_id", null: false
    t.uuid "recipient_id"
    t.index ["created_at"], name: "index_invitations_on_created_at"
    t.index ["family_id", "email"], name: "index_invitations_on_family_id_and_email", unique: true
    t.index ["family_id"], name: "index_invitations_on_family_id"
    t.index ["kinship_id"], name: "index_invitations_on_kinship_id"
    t.index ["recipient_id"], name: "index_invitations_on_recipient_id"
    t.index ["sender_id"], name: "index_invitations_on_sender_id"
  end

  create_table "kinships", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "integer_id"
    t.integer "integer_user_id"
    t.integer "integer_family_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nickname", null: false
    t.string "role", default: "guest", null: false
    t.jsonb "profile_attrs", default: {}, null: false
    t.string "description"
    t.bigint "integer_inviter_id"
    t.string "access_type", default: "default", null: false
    t.boolean "showcase", default: false, null: false
    t.uuid "family_id", null: false
    t.uuid "user_id"
    t.uuid "inviter_id"
    t.index ["created_at"], name: "index_kinships_on_created_at"
    t.index ["family_id"], name: "index_kinships_on_family_id"
    t.index ["inviter_id"], name: "index_kinships_on_inviter_id"
    t.index ["user_id", "family_id"], name: "index_kinships_on_user_id_and_family_id", unique: true, where: "(user_id IS NOT NULL)"
    t.index ["user_id"], name: "index_kinships_on_user_id"
  end

  create_table "ownership_transfers", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.bigint "integer_old_admin_id"
    t.bigint "integer_new_admin_id"
    t.bigint "integer_family_id"
    t.datetime "expires_at"
    t.string "status", default: "pending", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "family_id", null: false
    t.uuid "old_admin_id", null: false
    t.uuid "new_admin_id", null: false
    t.index ["created_at"], name: "index_ownership_transfers_on_created_at"
    t.index ["family_id"], name: "index_ownership_transfers_on_family_id"
    t.index ["new_admin_id"], name: "index_ownership_transfers_on_new_admin_id"
    t.index ["old_admin_id"], name: "index_ownership_transfers_on_old_admin_id"
  end

  create_table "publications", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "integer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "integer_family_id"
    t.integer "integer_story_id"
    t.date "publish_on"
    t.datetime "notified_at"
    t.string "share_type", default: "community", null: false
    t.integer "comments_count", default: 0, null: false
    t.integer "appreciations_count", default: 0, null: false
    t.integer "all_comments_count", default: 0, null: false
    t.bigint "integer_kinship_id"
    t.boolean "showcase", default: false, null: false
    t.uuid "story_id", null: false
    t.uuid "family_id", null: false
    t.uuid "kinship_id", null: false
    t.index ["created_at"], name: "index_publications_on_created_at"
    t.index ["family_id"], name: "index_publications_on_family_id"
    t.index ["kinship_id"], name: "index_publications_on_kinship_id"
    t.index ["notified_at"], name: "index_publications_on_notified_at"
    t.index ["publish_on"], name: "index_publications_on_publish_on"
    t.index ["story_id"], name: "index_publications_on_story_id"
  end

  create_table "read_marks", id: :serial, force: :cascade do |t|
    t.string "readable_type", null: false
    t.integer "integer_readable_id"
    t.integer "integer_reader_id"
    t.datetime "timestamp"
    t.string "reader_type"
    t.uuid "readable_id"
    t.uuid "reader_id", null: false
    t.index ["readable_id", "readable_type", "reader_id", "reader_type"], name: "read_marks_reader_readable_index", unique: true
  end

  create_table "registration_codes", force: :cascade do |t|
    t.string "code", limit: 5, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sections", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "integer_id"
    t.text "body"
    t.integer "integer_story_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", null: false
    t.integer "integer_author_id"
    t.string "title"
    t.integer "comments_count", default: 0, null: false
    t.integer "appreciations_count", default: 0, null: false
    t.bigint "integer_original_section_id"
    t.bigint "integer_kinship_id"
    t.boolean "showcase", default: false, null: false
    t.uuid "story_id", null: false
    t.uuid "original_section_id"
    t.uuid "kinship_id"
    t.uuid "author_id", null: false
    t.index ["author_id"], name: "index_sections_on_author_id"
    t.index ["created_at"], name: "index_sections_on_created_at"
    t.index ["kinship_id"], name: "index_sections_on_kinship_id"
    t.index ["original_section_id"], name: "index_sections_on_original_section_id"
    t.index ["position"], name: "index_sections_on_position"
    t.index ["story_id"], name: "index_sections_on_story_id"
  end

  create_table "stories", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "integer_id"
    t.string "title", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "date", default: "", null: false
    t.text "description", default: "", null: false
    t.integer "integer_user_id"
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
    t.integer "integer_original_story_id"
    t.boolean "showcase", default: false, null: false
    t.uuid "original_story_id"
    t.uuid "user_id", null: false
    t.index ["created_at"], name: "index_stories_on_created_at"
    t.index ["original_story_id"], name: "index_stories_on_original_story_id"
    t.index ["updated_at"], name: "index_stories_on_updated_at"
    t.index ["user_id"], name: "index_stories_on_user_id"
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
    t.index ["created_at"], name: "index_stripe_plans_on_created_at"
    t.index ["plan_id"], name: "index_stripe_plans_on_plan_id", unique: true
  end

  create_table "subscriptions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "integer_id"
    t.integer "integer_user_id"
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
    t.uuid "user_id", null: false
    t.index ["created_at"], name: "index_subscriptions_on_created_at"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "integer_taggable_id"
    t.string "tagger_type"
    t.integer "integer_tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.uuid "taggable_id", null: false
    t.uuid "tagger_id"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "integer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.hstore "metadata"
    t.string "first_name"
    t.string "last_name"
    t.datetime "confirmed_at"
    t.boolean "admin", default: false
    t.string "stripe_id"
    t.boolean "ability_all", default: true, null: false
    t.jsonb "onboarding", default: {}, null: false
    t.string "registration_method", default: "direct", null: false
    t.boolean "showcase", default: false, null: false
    t.boolean "terms_and_conditions", default: false, null: false
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["email"], name: "index_users_on_email"
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  create_table "vaults", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "integer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "owner_type", null: false
    t.bigint "integer_owner_id"
    t.uuid "owner_id", null: false
    t.index ["created_at"], name: "index_vaults_on_created_at"
    t.index ["owner_id", "owner_type"], name: "index_vaults_on_owner_id_and_owner_type"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "taggings", "tags"
end
