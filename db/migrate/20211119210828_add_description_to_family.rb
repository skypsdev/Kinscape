class AddDescriptionToFamily < ActiveRecord::Migration[6.1]
  def change
    add_column :families, :description, :text
  end
end
