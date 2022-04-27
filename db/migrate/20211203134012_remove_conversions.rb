class RemoveConversions < ActiveRecord::Migration[6.1]
  def up
    drop_table :conversions, if_exists: true
  end
  def down

  end
end
