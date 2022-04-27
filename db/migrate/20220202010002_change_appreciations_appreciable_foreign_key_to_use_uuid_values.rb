class ChangeAppreciationsAppreciableForeignKeyToUseUuidValues < ActiveRecord::Migration[6.1]
  def change
    remove_index :appreciations, name: 'index_appreciations_on_appreciable_type_and_appreciable_id'
    change_column_null :appreciations, :appreciable_id, true
    rename_column :appreciations, :appreciable_id, :appreciable_integer_id
    add_column :appreciations, :appreciable_id, :uuid
  end
end
