class ChangeCommentsToUseUuidAsPrimaryKey < ActiveRecord::Migration[6.1]
  def up
    remove_column :comments, :uuid
    add_column :comments, :uuid, :uuid, default: "uuid_generate_v4()", null: false
    rename_column :comments, :id, :integer_id
    rename_column :comments, :uuid, :id
    execute "ALTER TABLE comments DROP CONSTRAINT IF EXISTS comments_pkey;"
    execute "ALTER TABLE comments ADD PRIMARY KEY (id);"

    execute "ALTER TABLE ONLY comments ALTER COLUMN integer_id DROP DEFAULT;"
    change_column_null :comments, :integer_id, true
    execute "DROP SEQUENCE IF EXISTS comments_id_seq"

    change_column_null :comments, :commentable_id, true
    rename_column :comments, :commentable_id, :integer_commentable_id
    add_column :comments, :commentable_id, :uuid
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
