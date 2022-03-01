desc 'Migrate comments commentable'
task comments_migration: :environment do
  ActiveRecord::Base.transaction do
    Comment.includes(commentable: :publications).where(commentable_type: 'Story').find_each do |comment|
      next if comment.commentable.publications.size.zero?

      if comment.commentable.publications.size == 1
        comment.update!(commentable: comment.commentable.publications.first)
      else
        comment.commentable.publications.each do |publication|
          new_comment = comment.dup
          new_comment.commentable = publication
          new_comment.save!
        end
        comment.destroy!
      end
    end
  end
end
