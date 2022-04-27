class ChangeColumnsNullValues < ActiveRecord::Migration[6.1]
  def change
    change_column_null :action_text_rich_texts, :record_id, false

    change_column_null :active_storage_attachments, :record_id, false

    change_column_null :appreciations, :appreciable_id, false
    change_column_null :appreciations, :user_id, false

    change_column_null :boxes, :vault_id, false

    change_column_null :chapters, :author_id, false
    change_column_null :chapters, :chapterable_id, false

    change_column_null :comments, :publication_id, false
    change_column_null :comments, :commentable_id, false
    change_column_null :comments, :user_id, false

    change_column_null :family_subscriptions, :family_id, false
    change_column_null :family_subscriptions, :user_id, false

    change_column_null :invitations, :family_id, false
    change_column_null :invitations, :sender_id, false

    change_column_null :kinships, :family_id, false

    change_column_null :ownership_transfers, :family_id, false
    change_column_null :ownership_transfers, :old_admin_id, false
    change_column_null :ownership_transfers, :new_admin_id, false

    change_column_null :publications, :story_id, false
    change_column_null :publications, :family_id, false
    change_column_null :publications, :kinship_id, false

    change_column_null :read_marks, :reader_id, false

    change_column_null :sections, :story_id, false
    change_column_null :sections, :author_id, false

    change_column_null :stories, :user_id, false

    change_column_null :subscriptions, :user_id, false

    change_column_null :taggings, :taggable_id, false

    change_column_null :vaults, :owner_id, false
  end
end
