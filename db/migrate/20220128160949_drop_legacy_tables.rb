class DropLegacyTables < ActiveRecord::Migration[6.1]
  def change
    drop_table :attachments
    drop_table :media_files
  end
end
