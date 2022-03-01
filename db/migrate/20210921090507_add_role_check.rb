class AddRoleCheck < ActiveRecord::Migration[6.1]
  def change
    add_index :kinships, [:family_id, :role], unique: true, where: "role = 'admin'"
  end
end
