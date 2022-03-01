class AddUuidsToStories < ActiveRecord::Migration[6.0]
  def up
    add_column :stories,
               :uuid,
               :bigint,
               default: -> { 'random_uuid_bigint();' }

    add_index :stories, :uuid
  end

  def down
    remove_index :stories, :uuid
    remove_column :stories, :uuid
  end
end
