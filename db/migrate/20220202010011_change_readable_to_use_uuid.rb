class ChangeReadableToUseUuid < ActiveRecord::Migration[6.1]
  def change
    remove_index :read_marks, name: 'read_marks_reader_readable_index'
    change_column_null :read_marks, :readable_id, true
    rename_column :read_marks, :readable_id, :integer_readable_id
    add_column :read_marks, :readable_id, :uuid
    # add_index :read_marks, [:readable_id, :readable_type, :reader_id, :reader_type], unique: true
  end
end
