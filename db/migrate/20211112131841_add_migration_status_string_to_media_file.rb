class AddMigrationStatusStringToMediaFile < ActiveRecord::Migration[6.1]
  def change
    add_column :media_files, :migrated, :boolean, default: false, null: false
    add_column :media_files, :migration_error, :string
  end
end
