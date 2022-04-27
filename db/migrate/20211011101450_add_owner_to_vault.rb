class AddOwnerToVault < ActiveRecord::Migration[6.1]
  def change
    add_reference :vaults, :owner, polymorphic: true

    change_column_null :vaults, :owner_type, false
    change_column_null :vaults, :owner_id, false

    rename_column :vaults, :family_id, :legacy_family_id
    rename_column :vaults, :user_id, :legacy_user_id
  end
end
