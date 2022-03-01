class AddDevtoolFlagForAbility < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :ability_all, :boolean, default: true, null: false
    add_column :families, :ability_all, :boolean, default: true, null: false
  end
end
