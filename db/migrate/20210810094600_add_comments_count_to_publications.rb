class AddCommentsCountToPublications < ActiveRecord::Migration[6.0]
  def change
    add_column :publications, :comments_count, :integer, null: false, default: 0
  end
end
