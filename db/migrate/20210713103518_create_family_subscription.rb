class CreateFamilySubscription < ActiveRecord::Migration[6.0]
  def change
    create_table :family_subscriptions, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :family, index: true, foreign_key: true, null: false
      t.jsonb :billing_plan_data, null: false, default: {}
      t.string :stripe_id
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.boolean :cancel_at_period_end, null: false, default: false

      t.timestamps null: false
    end
  end
end
