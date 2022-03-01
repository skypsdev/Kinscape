class AddRoleToInvitation < ActiveRecord::Migration[6.0]
  def change
    add_column :invitations, :role, :string, null: false, default: "member"
  end
end
