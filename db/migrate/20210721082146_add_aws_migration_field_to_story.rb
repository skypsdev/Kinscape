class AddAwsMigrationFieldToStory < ActiveRecord::Migration[6.0]
  def change
    add_column :stories, :aws, :boolean
  end
end
