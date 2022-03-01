class AddUidsToBoxes < ActiveRecord::Migration[6.0]
  def change
    add_column :boxes, :uuid, :bigint, default: -> { 'random_uuid_bigint();' }
    add_index :boxes, :uuid
  end
end
