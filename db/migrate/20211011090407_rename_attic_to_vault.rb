class RenameAtticToVault < ActiveRecord::Migration[6.1]
  def change
    rename_table :attics, :vaults
    rename_column :boxes, :attic_id, :vault_id
  end
end
