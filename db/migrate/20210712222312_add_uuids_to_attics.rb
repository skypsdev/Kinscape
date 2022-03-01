class AddUuidsToAttics < ActiveRecord::Migration[6.0]
  def change
    add_column :attics, :uuid, :bigint, default: -> { 'random_uuid_bigint();' }
    add_index :attics, :uuid
  end
end
