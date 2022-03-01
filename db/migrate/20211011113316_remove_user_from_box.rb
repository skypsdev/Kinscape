class RemoveUserFromBox < ActiveRecord::Migration[6.1]
  def change
    rename_column :boxes, :user_id, :legacy_user_id
  end
end
