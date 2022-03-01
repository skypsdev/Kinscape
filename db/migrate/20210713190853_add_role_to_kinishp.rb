class AddRoleToKinishp < ActiveRecord::Migration[6.0]
  def change
    add_column :kinships, :role, :string, null: false, default: "guest"
  end
end
