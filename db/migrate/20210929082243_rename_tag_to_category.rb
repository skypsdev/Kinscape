class RenameTagToCategory < ActiveRecord::Migration[6.1]
  def change
    rename_column :stories, :tags, :categories
  end
end
