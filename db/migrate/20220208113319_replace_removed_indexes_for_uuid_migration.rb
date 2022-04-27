class ReplaceRemovedIndexesForUuidMigration < ActiveRecord::Migration[6.1]
  def change
    add_index :action_text_rich_texts, [:record_id, :record_type, :name], unique: true, name: 'index_action_text_rich_texts_uniqueness'
    add_index :read_marks, [:readable_id, :readable_type, :reader_id, :reader_type], unique: true, name: 'read_marks_reader_readable_index'
    add_index :active_storage_attachments, [:record_type, :record_id, :name, :blob_id, :copy_number, :box_id], name: 'index_active_storage_attachments_uniqueness_with_box', unique: true, where: '(box_id IS NOT NULL)'
    add_index :active_storage_attachments, [:record_type, :record_id, :name, :blob_id, :copy_number], name: 'index_active_storage_attachments_uniqueness', unique: true, where: '(box_id IS NULL)'

    add_index :taggings, ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    add_index :taggings, ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    add_index :taggings, ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    add_index :taggings, ["taggable_id"]
    add_index :taggings, ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    add_index :taggings, ["tagger_id"]

    add_index :active_storage_attachments, :box_id
    add_index :active_storage_attachments, :family_id
    add_index :active_storage_attachments, :user_id
    add_index :active_storage_variant_records, :blob_id
    add_index :appreciations, :user_id
    add_index :appreciations, [:appreciable_id, :appreciable_type]
    add_index :appreciations, [:user_id, :appreciable_id, :appreciable_type], unique: true, name: 'index_appreciation_user_uniqueness'
    add_index :boxes, :parent_box_id
    add_index :boxes, :vault_id
    add_index :boxes, ["name", "vault_id", "parent_box_id"], name: "index_boxes_on_name_and_vault_id_and_parent_box_id", unique: true
    add_index :boxes, ["name", "vault_id"], name: "index_boxes_on_name_and_vault_id", unique: true, where: "(parent_box_id IS NULL)"
    add_index :chapters, :author_id
    add_index :chapters, :kinship_id
    add_index :chapters, [:chapterable_id, :chapterable_type]
    add_index :comments, :publication_id
    add_index :comments, :user_id
    add_index :comments, [:commentable_id, :commentable_type]
    add_index :family_subscriptions, :family_id
    add_index :family_subscriptions, :user_id
    add_index :invitations, :family_id
    add_index :invitations, :kinship_id
    add_index :invitations, :recipient_id
    add_index :invitations, :sender_id
    add_index :invitations, [:family_id, :email], unique: true
    add_index :kinships, :family_id
    add_index :kinships, :inviter_id
    add_index :kinships, :user_id
    add_index :kinships, ["user_id", "family_id"], name: "index_kinships_on_user_id_and_family_id", unique: true, where: "(user_id IS NOT NULL)"
    add_index :ownership_transfers, :family_id
    add_index :ownership_transfers, :new_admin_id
    add_index :ownership_transfers, :old_admin_id
    add_index :publications, :family_id
    add_index :publications, :kinship_id
    add_index :publications, :story_id
    add_index :sections, :author_id
    add_index :sections, :kinship_id
    add_index :sections, :original_section_id
    add_index :sections, :story_id
    add_index :stories, :original_story_id
    add_index :stories, :user_id
    add_index :stripe_plans, [:plan_id], unique: true
    add_index :subscriptions, :user_id
    add_index :vaults, [:owner_id, :owner_type]
  end
end
