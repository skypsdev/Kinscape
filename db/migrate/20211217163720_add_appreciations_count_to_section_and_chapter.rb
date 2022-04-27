class AddAppreciationsCountToSectionAndChapter < ActiveRecord::Migration[6.1]
  def change
    add_column :chapters, :appreciations_count, :integer, null: false, default: 0
    add_column :sections, :appreciations_count, :integer, null: false, default: 0
  end
end
