class ChangeActionTextRecordForeignKeysToUseUuid < ActiveRecord::Migration[6.1]
  def change
    remove_index :action_text_rich_texts, name: 'index_action_text_rich_texts_uniqueness'
    change_column_null :action_text_rich_texts, :record_id, true
    rename_column :action_text_rich_texts, :record_id, :record_integer_id
    add_column :action_text_rich_texts, :record_id, :uuid
  end
end
