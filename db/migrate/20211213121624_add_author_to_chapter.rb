class AddAuthorToChapter < ActiveRecord::Migration[6.1]
  def change
    add_reference :chapters, :author

    Chapter.includes(:chapterable).find_each do |chapter|
      chapter.destroy if chapter.chapterable.nil?

      author_id = case chapter.chapterable_type
                  when 'Kinship'
                    chapter.chapterable.user_id ||  chapter.chapterable.family.admin.id
                  when 'Family'
                    chapter.chapterable.admin.id
                  end
      chapter.update!(author_id: author_id)
    end

    change_column_null :chapters, :author_id, false
  end
end
