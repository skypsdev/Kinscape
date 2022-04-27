class RemoveMediaType < ActiveRecord::Migration[6.1]
  def change
    remove_column :sections, :media_type, :string
    remove_column :chapters, :media_type, :string
  end
end
