class AddTopCommentableToComments < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :top_commentable_id, :uuid
    add_column :comments, :top_commentable_type, :string

    Comment.find_each do |comment|
      comment.update(top_commentable_id: comment.publication_id, top_commentable_type: 'Publication')
    end

    change_column_null :comments, :top_commentable_id, false
    change_column_null :comments, :top_commentable_type, false

    remove_column :comments, :publication_id
  end
end
