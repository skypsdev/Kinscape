class RenameStoriesTags < ActiveRecord::Migration[6.1]
  def change
    rename_column :stories, :categories, :legacy_categories
  end
end
