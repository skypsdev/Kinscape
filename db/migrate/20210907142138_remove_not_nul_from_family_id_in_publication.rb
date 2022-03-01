class RemoveNotNulFromFamilyIdInPublication < ActiveRecord::Migration[6.0]
  def change
    change_column_null :publications, :family_id, true
  end
end
