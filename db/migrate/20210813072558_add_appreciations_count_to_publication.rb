class AddAppreciationsCountToPublication < ActiveRecord::Migration[6.0]
  def change
    add_column :publications, :appreciations_count, :integer, null: false, default: 0
  end
end
