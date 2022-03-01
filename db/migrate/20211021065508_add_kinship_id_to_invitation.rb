class AddKinshipIdToInvitation < ActiveRecord::Migration[6.1]
  def change
    add_column :invitations, :kinship_id, :integer
  end
end
