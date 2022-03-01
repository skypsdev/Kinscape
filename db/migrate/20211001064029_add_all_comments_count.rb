class AddAllCommentsCount < ActiveRecord::Migration[6.1]
  def change
    add_column :publications, :all_comments_count, :integer, null: false, default: 0
  end
end
