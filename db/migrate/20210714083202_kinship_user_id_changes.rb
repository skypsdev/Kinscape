class KinshipUserIdChanges < ActiveRecord::Migration[6.0]
  def change
    change_column_null :kinships, :user_id, true
    add_index :kinships, %i[user_id family_id], unique: true, where: 'user_id IS NOT NULL'
  end
end
