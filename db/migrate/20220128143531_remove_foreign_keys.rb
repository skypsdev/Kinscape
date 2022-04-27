class RemoveForeignKeys < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :attachments, :boxes
    remove_foreign_key :media_files, :users
    remove_foreign_key :vaults, :families
    remove_foreign_key :vaults, :users
    remove_foreign_key :families, :users
    remove_foreign_key :boxes, :users
  end
end
