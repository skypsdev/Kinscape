class MigrateAttachmentsRecordIdToUseUuid < ActiveRecord::Migration[6.1]
  def change
    remove_index :active_storage_attachments, name: 'index_active_storage_attachments_uniqueness'
    remove_index :active_storage_attachments, name: 'index_active_storage_attachments_uniqueness_with_box'
    change_column_null :active_storage_attachments, :record_id, true
    rename_column :active_storage_attachments, :record_id, :integer_record_id
    add_column :active_storage_attachments, :record_id, :uuid
    # add_index :active_storage_attachments,
    #   [:record_type, :record_id, :name, :blob_id, :copy_number],
    #   name: :index_active_storage_attachments_uniqueness,
    #   unique: true, where: "box_id is null"
    # add_index :active_storage_attachments,
    #   [:record_type, :record_id, :name, :blob_id, :copy_number, :box_id],
    #   name: :index_active_storage_attachments_uniqueness_with_box,
    #   unique: true, where: "box_id is not null"
  end
end
