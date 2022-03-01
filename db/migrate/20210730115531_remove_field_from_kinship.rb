class RemoveFieldFromKinship < ActiveRecord::Migration[6.0]
  def change
    remove_column :kinships, :is_invitation_accept, :boolean, default: false
  end
end
