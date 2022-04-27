class ChangeKinshipTableToUseUuid < ActiveRecord::Migration[6.1]
  def up
    remove_index :chapters, :kinship_id
    remove_index :publications, :kinship_id
    remove_index :sections, :kinship_id

    add_column :kinships, :uuid, :uuid, default: "uuid_generate_v4()", null: false
    rename_column :kinships, :id, :integer_id
    rename_column :kinships, :uuid, :id
    execute "ALTER TABLE kinships DROP CONSTRAINT IF EXISTS kinships_pkey;"
    execute "ALTER TABLE kinships ADD PRIMARY KEY (id);"

    execute "ALTER TABLE ONLY kinships ALTER COLUMN integer_id DROP DEFAULT;"
    change_column_null :kinships, :integer_id, true
    execute "DROP SEQUENCE IF EXISTS kinships_id_seq"

    change_column_null :sections, :kinship_id, true
    rename_column :sections, :kinship_id, :integer_kinship_id
    add_column :sections, :kinship_id, :uuid

    change_column_null :chapters, :kinship_id, true
    rename_column :chapters, :kinship_id, :integer_kinship_id
    add_column :chapters, :kinship_id, :uuid

    change_column_null :invitations, :kinship_id, true
    rename_column :invitations, :kinship_id, :integer_kinship_id
    add_column :invitations, :kinship_id, :uuid

    change_column_null :publications, :kinship_id, true
    rename_column :publications, :kinship_id, :integer_kinship_id
    add_column :publications, :kinship_id, :uuid
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
