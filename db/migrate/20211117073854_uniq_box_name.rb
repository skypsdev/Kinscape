class UniqBoxName < ActiveRecord::Migration[6.1]
  def change
    change_column_default :boxes, :name, from: "", to: nil

    Box.all.pluck(:vault_id, :name).tally.each do |array, count|
      next if count == 1

      vault_id = array[0]
      name = array[1]

      Box.where(vault_id: vault_id, name: name).each_with_index do |box, index|
        box.update!(name: "#{name}_#{index}")
      end
    end
    add_index :boxes, [:name, :vault_id], unique: true, where: "parent_box_id IS NULL"
    add_index :boxes, [:name, :vault_id, :parent_box_id], unique: true
  end
end
