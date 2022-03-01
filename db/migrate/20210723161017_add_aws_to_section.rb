class AddAwsToSection < ActiveRecord::Migration[6.0]
  def change
    add_column :sections, :aws, :boolean
  end
end
