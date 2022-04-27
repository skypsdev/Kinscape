class RemoveLegacyColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :boxes, :legacy_user_id, :integer
    remove_column :families, :old_cover, :string
    remove_column :families, :legacy_connector_id, :integer
    remove_column :families, :storage_size, :bigint
    remove_column :invitations, :first_name, :string
    remove_column :invitations, :last_name, :string
    remove_column :kinships, :location, :string
    remove_column :kinships, :birth_date, :string
    remove_column :kinships, :birth_place, :string
    remove_column :kinships, :address, :string
    remove_column :kinships, :phone, :string
    remove_column :kinships, :email, :string
    remove_column :kinships, :death_date, :string
    remove_column :sections, :aws, :boolean
    remove_column :stories, :aws, :boolean
    remove_column :stories, :legacy_categories, :string
    remove_column :users, :old_avatar, :string
    remove_column :users, :tour_completed, :string
    remove_column :users, :caretaker_id, :string
    remove_column :users, :title, :string
    remove_column :users, :storage_size, :string
    remove_column :vaults, :legacy_user_id, :integer
    remove_column :vaults, :legacy_family_id, :integer
  end
end
