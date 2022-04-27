class AddPersonalFlagToFamilyAndKinship < ActiveRecord::Migration[6.1]
  def change
    add_column :families, :personal, :boolean, default: false, null: false
    add_column :kinships, :personal, :boolean, default: false, null: false
  end
end
