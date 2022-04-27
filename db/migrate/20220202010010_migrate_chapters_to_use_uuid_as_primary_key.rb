class MigrateChaptersToUseUuidAsPrimaryKey < ActiveRecord::Migration[6.1]
  def up
    add_column :chapters, :uuid, :uuid, default: "uuid_generate_v4()", null: false
    rename_column :chapters, :id, :integer_id
    rename_column :chapters, :uuid, :id
    execute "ALTER TABLE chapters DROP CONSTRAINT IF EXISTS chapters_pkey;"
    execute "ALTER TABLE chapters ADD PRIMARY KEY (id);"

    execute "ALTER TABLE ONLY chapters ALTER COLUMN integer_id DROP DEFAULT;"
    change_column_null :chapters, :integer_id, true
    execute "DROP SEQUENCE IF EXISTS chapters_id_seq"

    change_column_null :chapters, :chapterable_id, true
    rename_column :chapters, :chapterable_id, :integer_chapterable_id
    add_column :chapters, :chapterable_id, :uuid
    # add_index :chapters, [:chapterable_id, :chapterable_type]
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
