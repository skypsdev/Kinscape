class AddAuthorToChapter < ActiveRecord::Migration[6.1]
  def change
    add_reference :chapters, :author
    change_column_null :chapters, :author_id, false
  end
end
