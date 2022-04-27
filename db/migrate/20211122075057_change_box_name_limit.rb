class ChangeBoxNameLimit < ActiveRecord::Migration[6.1]
  def up
    change_column :boxes, :name, :string, null: false, limit: 50
  end

  def down
    change_column :boxes, :name, :string
  end
end
