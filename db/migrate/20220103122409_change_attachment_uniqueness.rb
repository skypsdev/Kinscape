class ChangeAttachmentUniqueness < ActiveRecord::Migration[6.1]
  def change
    add_column :active_storage_attachments, :copy_number, :integer, null: false, default: 0
    remove_index :active_storage_attachments,
                 [:record_type, :record_id, :name, :blob_id],
                 name: :index_active_storage_attachments_uniqueness
    add_index :active_storage_attachments,
              [:record_type, :record_id, :name, :blob_id, :copy_number],
              name: :index_active_storage_attachments_uniqueness,
              unique: true, where: "box_id is null"
    add_index :active_storage_attachments,
              [:record_type, :record_id, :name, :blob_id, :copy_number, :box_id],
              name: :index_active_storage_attachments_uniqueness_with_box,
              unique: true, where: "box_id is not null"
  end
end
