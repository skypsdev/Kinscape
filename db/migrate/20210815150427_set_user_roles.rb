class SetUserRoles < ActiveRecord::Migration[6.0]
  def change
    Kinship.update_all(role: 'member')
  end
end
