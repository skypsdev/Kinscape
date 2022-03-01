class AddOriginalStoryToStory < ActiveRecord::Migration[6.0]
  def change
    add_column :stories, :original_story_id, :integer
  end
end
