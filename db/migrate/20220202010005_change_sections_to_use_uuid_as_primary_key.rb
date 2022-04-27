class ChangeSectionsToUseUuidAsPrimaryKey < ActiveRecord::Migration[6.1]
  def up
    add_column :sections, :uuid, :uuid, default: "uuid_generate_v4()", null: false
    rename_column :sections, :id, :integer_id
    rename_column :sections, :uuid, :id
    execute "ALTER TABLE sections DROP CONSTRAINT IF EXISTS sections_pkey;"
    execute "ALTER TABLE sections ADD PRIMARY KEY (id);"

    execute "ALTER TABLE ONLY sections ALTER COLUMN integer_id DROP DEFAULT;"
    change_column_null :sections, :integer_id, true
    execute "DROP SEQUENCE IF EXISTS sections_id_seq"

    add_index :sections, :created_at

    remove_index :sections, :original_section_id
    rename_column :sections, :original_section_id, :integer_original_section_id
    add_column :sections, :original_section_id, :uuid
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
