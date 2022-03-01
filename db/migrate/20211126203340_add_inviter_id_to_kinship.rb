class AddInviterIdToKinship < ActiveRecord::Migration[6.1]
  def change
    add_reference :kinships, :inviter
  end
end
