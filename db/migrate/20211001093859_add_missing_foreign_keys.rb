class AddMissingForeignKeys < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :stories, :users
    add_foreign_key :sections, :users, column: :author_id
  end
end
