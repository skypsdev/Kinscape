class ChangeFamilyTableToUseUuid < ActiveRecord::Migration[6.1]
  def up
    remove_foreign_key :family_subscriptions, :families
    remove_foreign_key :ownership_transfers, :families

    remove_column :families, :uuid
    add_column :families, :uuid, :uuid, default: "uuid_generate_v4()", null: false
    rename_column :families, :id, :integer_id
    rename_column :families, :uuid, :id
    execute "ALTER TABLE families DROP CONSTRAINT IF EXISTS families_pkey;"
    execute "ALTER TABLE families ADD PRIMARY KEY (id);"

    execute "ALTER TABLE ONLY families ALTER COLUMN integer_id DROP DEFAULT;"
    change_column_null :families, :integer_id, true
    execute "DROP SEQUENCE IF EXISTS families_id_seq"

    add_index :families, :created_at

    #family subscriptions
    remove_index :family_subscriptions, :family_id
    change_column_null :family_subscriptions, :family_id, true
    rename_column :family_subscriptions, :family_id, :integer_family_id
    add_column :family_subscriptions, :family_id, :uuid

    # invitations
    remove_index :invitations, :family_id
    change_column_null :invitations, :family_id, true
    rename_column :invitations, :family_id, :integer_family_id
    add_column :invitations, :family_id, :uuid

    # kinships
    remove_index :kinships, ["family_id", "role"]
    remove_index :kinships, ["user_id", "family_id"]
    change_column_null :kinships, :family_id, true
    rename_column :kinships, :family_id, :integer_family_id
    add_column :kinships, :family_id, :uuid

    # ownership transfers
    remove_index :ownership_transfers, :family_id
    change_column_null :ownership_transfers, :family_id, true
    rename_column :ownership_transfers, :family_id, :integer_family_id
    add_column :ownership_transfers, :family_id, :uuid

    # publications
    remove_index :publications, :family_id
    change_column_null :publications, :family_id, true
    rename_column :publications, :family_id, :integer_family_id
    add_column :publications, :family_id, :uuid

    # active_storage_attachments
    remove_index :active_storage_attachments, :family_id
    # change_column_null :active_storage_attachments, :family_id, true
    rename_column :active_storage_attachments, :family_id, :integer_family_id
    add_column :active_storage_attachments, :family_id, :uuid
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
