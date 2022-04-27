class AddCreatedAtIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :chapters, :created_at
    add_index :comments, :created_at
    add_index :family_subscriptions, :created_at
    add_index :invitations, :created_at
    add_index :kinships, :created_at
    add_index :ownership_transfers, :created_at
    add_index :stripe_plans, :created_at
    add_index :vaults, :created_at
  end
end
