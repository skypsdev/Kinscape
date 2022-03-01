class AddPublicationType < ActiveRecord::Migration[6.0]
  def change
    add_column :publications, :share_type, :string, null: false, default: 'community'
  end
end
