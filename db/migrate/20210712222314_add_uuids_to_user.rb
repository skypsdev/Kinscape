class AddUuidsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :uuid, :bigint, default: -> { 'random_uuid_bigint();' }
    add_index :users, :uuid
  end
end
