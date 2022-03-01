class AddUuidsToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :uuid, :bigint, default: -> { 'random_uuid_bigint();' }
    add_index :comments, :uuid
  end
end
