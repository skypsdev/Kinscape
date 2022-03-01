class AddUuidColumnAsPrimaryKeyToCommunities < ActiveRecord::Migration[6.0]
  def up
    add_column :families,
               :uuid,
               :bigint,
               default: -> { 'random_uuid_bigint();' }

    add_index :families, :uuid
  end

  def down
    remove_index :families, :uuid
    remove_column :families, :uuid
  end
end
