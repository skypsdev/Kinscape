class AddUuidToUsers < ActiveRecord::Migration[6.1]
  def up
    remove_foreign_key :subscriptions, :users
    remove_foreign_key :family_subscriptions, :users
    remove_foreign_key :stories, :users
    remove_foreign_key :sections, :users
    remove_foreign_key :appreciations, :users

    remove_index :active_storage_attachments, :user_id
    remove_index :appreciations, :user_id
    remove_index :appreciations, ["user_id", "appreciable_type", "appreciable_integer_id"]
    remove_index :chapters, :author_id
    remove_index :family_subscriptions, :user_id
    remove_index :kinships, :inviter_id
    remove_index :ownership_transfers, :new_admin_id
    remove_index :ownership_transfers, :old_admin_id
    remove_index :stories, :user_id
    remove_index :subscriptions, :user_id

    remove_column :users, :uuid
    add_column :users, :uuid, :uuid, default: "uuid_generate_v4()", null: false
    rename_column :users, :id, :integer_id
    rename_column :users, :uuid, :id
    execute "ALTER TABLE users DROP CONSTRAINT IF EXISTS users_pkey;"
    execute "ALTER TABLE users ADD PRIMARY KEY (id);"

    execute "ALTER TABLE ONLY users ALTER COLUMN integer_id DROP DEFAULT;"
    change_column_null :users, :integer_id, true
    execute "DROP SEQUENCE IF EXISTS users_id_seq"

    add_index :users, :created_at

    change_column_null :active_storage_attachments, :user_id, true
    rename_column :active_storage_attachments, :user_id, :integer_user_id
    add_column :active_storage_attachments, :user_id, :uuid

    change_column_null :appreciations, :user_id, true
    rename_column :appreciations, :user_id, :integer_user_id
    add_column :appreciations, :user_id, :uuid

    change_column_null :comments, :user_id, true
    rename_column :comments, :user_id, :integer_user_id
    add_column :comments, :user_id, :uuid

    change_column_null :family_subscriptions, :user_id, true
    rename_column :family_subscriptions, :user_id, :integer_user_id
    add_column :family_subscriptions, :user_id, :uuid

    change_column_null :kinships, :user_id, true
    rename_column :kinships, :user_id, :integer_user_id
    add_column :kinships, :user_id, :uuid

    change_column_null :kinships, :inviter_id, true
    rename_column :kinships, :inviter_id, :integer_inviter_id
    add_column :kinships, :inviter_id, :uuid

    change_column_null :stories, :user_id, true
    rename_column :stories, :user_id, :integer_user_id
    add_column :stories, :user_id, :uuid

    change_column_null :subscriptions, :user_id, true
    rename_column :subscriptions, :user_id, :integer_user_id
    add_column :subscriptions, :user_id, :uuid

    change_column_null :ownership_transfers, :old_admin_id, true
    rename_column :ownership_transfers, :old_admin_id, :integer_old_admin_id
    add_column :ownership_transfers, :old_admin_id, :uuid

    change_column_null :ownership_transfers, :new_admin_id, true
    rename_column :ownership_transfers, :new_admin_id, :integer_new_admin_id
    add_column :ownership_transfers, :new_admin_id, :uuid

    change_column_null :sections, :author_id, true
    rename_column :sections, :author_id, :integer_author_id
    add_column :sections, :author_id, :uuid

    change_column_null :chapters, :author_id, true
    rename_column :chapters, :author_id, :integer_author_id
    add_column :chapters, :author_id, :uuid

    change_column_null :invitations, :sender_id, true
    rename_column :invitations, :sender_id, :integer_sender_id
    add_column :invitations, :sender_id, :uuid

    change_column_null :invitations, :recipient_id, true
    rename_column :invitations, :recipient_id, :integer_recipient_id
    add_column :invitations, :recipient_id, :uuid

    change_column_null :read_marks, :reader_id, true
    rename_column :read_marks, :reader_id, :integer_reader_id
    add_column :read_marks, :reader_id, :uuid

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
