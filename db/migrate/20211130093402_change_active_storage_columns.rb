class ChangeActiveStorageColumns < ActiveRecord::Migration[6.1]
  def change
    add_reference :active_storage_attachments, :user
    add_reference :active_storage_attachments, :family
    add_column :active_storage_attachments, :title, :string

    remove_reference :active_storage_blobs, :user
    remove_reference :active_storage_blobs, :family
    remove_column :active_storage_blobs, :title, :string
  end
end
