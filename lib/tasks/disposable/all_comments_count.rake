desc 'Fill all comments count'
task all_comments_count: :environment do
  ActiveRecord::Base.transaction do
    Publication.find_each do |publication|
      Publication.reset_counters(publication.id, :all_comments_count)
    end
  end
end
