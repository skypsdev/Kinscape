class AddColumnsToActiveStorage < ActiveRecord::Migration[6.1]
  def change
    add_reference :active_storage_attachments, :box
    add_reference :active_storage_blobs, :user
    add_reference :active_storage_blobs, :family
    add_column :active_storage_blobs, :title, :string
  end
end
