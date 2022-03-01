class AddCommentsCountToSection < ActiveRecord::Migration[6.0]
  def change
    add_column :sections, :comments_count, :integer, default: 0, null: false
  end
end
