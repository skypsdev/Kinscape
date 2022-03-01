class AddColumnsToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :comments_count, :integer, default: 0, null: false
    add_reference :comments, :publication
  end
end
