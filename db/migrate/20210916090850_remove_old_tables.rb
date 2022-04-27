class RemoveOldTables < ActiveRecord::Migration[6.0]
  def up
    drop_table :table_of_chapters, if_exists: true
    drop_table :table_of_contents, if_exists: true
  end
  def down

  end
end
