class AddFamilyTypeToFamily < ActiveRecord::Migration[6.0]
  def change
    add_column :families, :family_type, :string, default: "Community", null: false
  end
end
