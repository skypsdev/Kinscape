class AddContributorsCountToStories < ActiveRecord::Migration[6.0]
  def change
    add_column :stories, :contributors_count, :integer, default: 0, null: false
  end
end
