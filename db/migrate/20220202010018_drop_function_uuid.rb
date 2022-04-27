class DropFunctionUuid < ActiveRecord::Migration[6.1]
  def up
    drop_function :random_uuid_bigint
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
