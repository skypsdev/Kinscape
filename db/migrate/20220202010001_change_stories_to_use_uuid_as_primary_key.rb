class ChangeStoriesToUseUuidAsPrimaryKey < ActiveRecord::Migration[6.1]
  def up
    remove_column :stories, :uuid

    add_column :stories, :uuid, :uuid, default: "uuid_generate_v4()", null: false
    rename_column :stories, :id, :integer_id
    rename_column :stories, :uuid, :id
    execute "ALTER TABLE stories DROP CONSTRAINT IF EXISTS stories_pkey;"
    execute "ALTER TABLE stories ADD PRIMARY KEY (id);"

    execute "ALTER TABLE ONLY stories ALTER COLUMN integer_id DROP DEFAULT;"
    change_column_null :stories, :integer_id, true
    execute "DROP SEQUENCE IF EXISTS stories_id_seq"

    add_index :stories, :created_at

    remove_index :publications, :story_id
    change_column_null :publications, :story_id, true
    rename_column :publications, :story_id, :integer_story_id
    add_column :publications, :story_id, :uuid

    remove_index :sections, :story_id
    change_column_null :sections, :story_id, true
    rename_column :sections, :story_id, :integer_story_id
    add_column :sections, :story_id, :uuid

    change_column_null :stories, :original_story_id, true
    rename_column :stories, :original_story_id, :integer_original_story_id
    add_column :stories, :original_story_id, :uuid
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
