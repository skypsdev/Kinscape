class MakeCommentsCountNonNullableInStories < ActiveRecord::Migration[6.0]
  def change
    change_column_default :stories, :comments_count, from: nil, to: 0
    change_column_null :stories, :comments_count, false, 0
  end
end
