class AddUuidToBox < ActiveRecord::Migration[6.1]
  def up
    remove_column :boxes, :uuid
    add_column :boxes, :uuid, :uuid, default: "uuid_generate_v4()", null: false
    rename_column :boxes, :id, :integer_id
    rename_column :boxes, :uuid, :id
    execute "ALTER TABLE boxes DROP CONSTRAINT IF EXISTS boxes_pkey;"
    execute "ALTER TABLE boxes ADD PRIMARY KEY (id);"

    execute "ALTER TABLE ONLY boxes ALTER COLUMN integer_id DROP DEFAULT;"
    change_column_null :boxes, :integer_id, true
    execute "DROP SEQUENCE IF EXISTS boxes_id_seq"

    add_index :boxes, :created_at

    remove_index :boxes, ["name", "integer_vault_id", "parent_box_id"]
    change_column_null :boxes, :parent_box_id, true
    rename_column :boxes, :parent_box_id, :integer_parent_box_id
    add_column :boxes, :parent_box_id, :uuid

    remove_index :active_storage_attachments, :box_id
    change_column_null :active_storage_attachments, :box_id, true
    rename_column :active_storage_attachments, :box_id, :integer_box_id
    add_column :active_storage_attachments, :box_id, :uuid


  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
