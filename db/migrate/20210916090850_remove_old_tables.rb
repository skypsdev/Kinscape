class RemoveOldTables < ActiveRecord::Migration[6.0]
  def change
    drop_table :table_of_chapters
    drop_table :table_of_contents
  end
end
