class AddSectionsCountToStories < ActiveRecord::Migration[6.0]
  def change
    add_column :stories, :sections_count, :integer, default: 0, null: false
    
    Story.all.each do |story|
      Story.reset_counters(story.id, :sections)
    end
  end
end
