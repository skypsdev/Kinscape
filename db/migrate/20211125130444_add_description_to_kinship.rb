class AddDescriptionToKinship < ActiveRecord::Migration[6.1]
  def change
    add_column :kinships, :description, :string
  end
end
