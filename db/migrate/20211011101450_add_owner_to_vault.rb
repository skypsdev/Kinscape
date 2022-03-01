class AddOwnerToVault < ActiveRecord::Migration[6.1]
  def change
    add_reference :vaults, :owner, polymorphic: true

    ActiveRecord::Base.transaction do
      Vault.find_each do |vault|
        if vault.family_id.present?
          vault.update!(owner_id: vault.family_id, owner_type: Family)
        elsif vault.user_id.present?
          vault.update!(owner_id: vault.user_id, owner_type: User)
        end
      end
      Attachment.where(containable_type: "Attic").update_all(containable_type: "Vault")
    end

    change_column_null :vaults, :owner_type, false
    change_column_null :vaults, :owner_id, false

    rename_column :vaults, :family_id, :legacy_family_id
    rename_column :vaults, :user_id, :legacy_user_id
  end
end
