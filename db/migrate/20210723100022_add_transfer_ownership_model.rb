class AddTransferOwnershipModel < ActiveRecord::Migration[6.0]
  def change
    create_table :ownership_transfers, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.references :old_admin, index: true, null: false
      t.references :new_admin, index: true, null: false
      t.references :family, foreign_key: true, null: false
      t.datetime :expires_at
      t.string :status, null: false, default: 'pending'

      t.timestamps null: false
    end
  end
end
