class AddSectionsCountToStories < ActiveRecord::Migration[6.0]
  def change
    add_column :stories, :sections_count, :integer, default: 0, null: false
  end
end
