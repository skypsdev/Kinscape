class AddContributorsCountToStories < ActiveRecord::Migration[6.0]
  def change
    add_column :stories, :contributors_count, :integer, default: 0, null: false

    # Set up the defaults
    # Story.all.each(&:update_contributors_count!)
  end
end
