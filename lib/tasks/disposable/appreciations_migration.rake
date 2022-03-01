desc 'Migrate appreciations appreciable'
task appreciations_migration: :environment do
  ActiveRecord::Base.transaction do
    Appreciation.includes(appreciable: :publications).where(appreciable_type: 'Story').find_each do |appreciation|
      if appreciation.appreciable.nil? || appreciation.appreciable.publications.size.zero?
        appreciation.destroy!
      elsif appreciation.appreciable.publications.size == 1
        appreciation.update!(appreciable: appreciation.appreciable.publications.first)
      else
        appreciation.appreciable.publications.each do |publication|
          new_appreciation = appreciation.dup
          new_appreciation.appreciable = publication
          new_appreciation.save!
        end
        appreciation.destroy!
      end
    end
  end
end
