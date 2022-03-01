class AddParentBoxIdToBoxes < ActiveRecord::Migration[6.1]
  def change
    add_column :boxes, :parent_box_id, :bigint
  end
end
