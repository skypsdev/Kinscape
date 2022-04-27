class AddUuidToSubscriptions < ActiveRecord::Migration[6.1]
  def up
    add_column :subscriptions, :uuid, :uuid, default: "uuid_generate_v4()", null: false
    rename_column :subscriptions, :id, :integer_id
    rename_column :subscriptions, :uuid, :id
    execute "ALTER TABLE subscriptions DROP CONSTRAINT IF EXISTS subscriptions_pkey;"
    execute "ALTER TABLE subscriptions ADD PRIMARY KEY (id);"

    execute "ALTER TABLE ONLY subscriptions ALTER COLUMN integer_id DROP DEFAULT;"
    change_column_null :subscriptions, :integer_id, true
    execute "DROP SEQUENCE IF EXISTS subscriptions_id_seq"

    add_index :subscriptions, :created_at
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
