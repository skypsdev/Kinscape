desc 'Create private publications'
task private_publications: :environment do
  ActiveRecord::Base.transaction do
    Story.where(original_story_id: nil).find_each do |story|
      story.publications.create(share_type: :private)
    end
  end
end
