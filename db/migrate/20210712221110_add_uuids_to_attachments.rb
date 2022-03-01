class AddUuidsToAttachments < ActiveRecord::Migration[6.0]
  def change
    add_column :attachments, :uuid, :bigint, default: -> { 'random_uuid_bigint();' }
    add_index :attachments, :uuid
  end
end
