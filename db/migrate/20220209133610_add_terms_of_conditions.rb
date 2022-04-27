class AddTermsOfConditions < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :terms_and_conditions, :boolean, null: false, default: false
    User.update_all(terms_and_conditions: true)
  end
end
