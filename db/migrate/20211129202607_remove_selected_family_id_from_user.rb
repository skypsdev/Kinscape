class RemoveSelectedFamilyIdFromUser < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :selected_family_id, :integer
  end
end
