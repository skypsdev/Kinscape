class RemoveMediaFilesIds < ActiveRecord::Migration[6.1]
  def change
    remove_column :families, :cover_image_id, :string
    remove_column :stories, :cover_image_id, :string
    remove_column :kinships, :media_avatar_id, :string
    remove_column :users, :avatar_id, :string
  end
end
