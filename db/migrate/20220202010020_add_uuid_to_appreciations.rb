class AddUuidToAppreciations < ActiveRecord::Migration[6.1]
  def up
    add_column :appreciations, :uuid, :uuid, default: "uuid_generate_v4()", null: false
    rename_column :appreciations, :id, :integer_id
    rename_column :appreciations, :uuid, :id
    execute "ALTER TABLE appreciations DROP CONSTRAINT IF EXISTS appreciations_pkey;"
    execute "ALTER TABLE appreciations ADD PRIMARY KEY (id);"

    execute "ALTER TABLE ONLY appreciations ALTER COLUMN integer_id DROP DEFAULT;"
    change_column_null :appreciations, :integer_id, true
    execute "DROP SEQUENCE IF EXISTS appreciations_id_seq"

    add_index :appreciations, :created_at
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
