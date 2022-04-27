class UniqBoxName < ActiveRecord::Migration[6.1]
  def change
    change_column_default :boxes, :name, from: "", to: nil

    add_index :boxes, [:name, :vault_id], unique: true, where: "parent_box_id IS NULL"
    add_index :boxes, [:name, :vault_id, :parent_box_id], unique: true
  end
end
