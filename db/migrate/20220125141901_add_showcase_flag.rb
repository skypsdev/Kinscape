class AddShowcaseFlag < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :showcase, :boolean, null: false, default: false
    add_column :families, :showcase, :boolean, null: false, default: false
    add_column :stories, :showcase, :boolean, null: false, default: false
    add_column :kinships, :showcase, :boolean, null: false, default: false
    add_column :publications, :showcase, :boolean, null: false, default: false
    add_column :invitations, :showcase, :boolean, null: false, default: false
    add_column :chapters, :showcase, :boolean, null: false, default: false
    add_column :sections, :showcase, :boolean, null: false, default: false
  end
end
