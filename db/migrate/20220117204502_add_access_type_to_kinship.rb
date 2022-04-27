class AddAccessTypeToKinship < ActiveRecord::Migration[6.1]
  def change
    add_column :kinships, :access_type, :string, null: false, default: 'default'

    Kinship.where(personal: true).update_all(access_type: 'personal')

    remove_column :kinships, :personal
  end
end
