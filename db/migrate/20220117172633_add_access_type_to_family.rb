class AddAccessTypeToFamily < ActiveRecord::Migration[6.1]
  def change
    add_column :families, :access_type, :string, null: false, default: 'default'

    Family.where(personal: true).update_all(access_type: 'personal')

    remove_column :families, :personal
  end
end
