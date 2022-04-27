class MigrateActionTextRichTextsPkToUuid < ActiveRecord::Migration[6.1]
  def change
    add_column :action_text_rich_texts, :uuid, :uuid, default: 'uuid_generate_v4()', null: false
    rename_column :action_text_rich_texts, :id, :integer_id
    rename_column :action_text_rich_texts, :uuid, :id
    execute 'ALTER TABLE action_text_rich_texts DROP CONSTRAINT IF EXISTS action_text_rich_texts_pkey;'
    execute 'ALTER TABLE action_text_rich_texts ADD PRIMARY KEY (id);'

    execute 'ALTER TABLE ONLY action_text_rich_texts ALTER COLUMN integer_id DROP DEFAULT;'
    change_column_null :action_text_rich_texts, :integer_id, true
    execute 'DROP SEQUENCE IF EXISTS action_text_rich_texts_id_seq'
  end
end
