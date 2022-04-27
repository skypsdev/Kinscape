class AddOnboardingToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :onboarding, :jsonb, null: false, default: {}
    add_column :users, :registration_method, :string, null: false, default: 'direct'
  end
end
