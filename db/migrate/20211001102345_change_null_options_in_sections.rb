class ChangeNullOptionsInSections < ActiveRecord::Migration[6.1]
  def change
    change_column_null :sections, :author_id, false
    change_column_null :sections, :story_id, false
  end
end
