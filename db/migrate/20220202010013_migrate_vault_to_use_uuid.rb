class MigrateVaultToUseUuid < ActiveRecord::Migration[6.1]
  def up
    # Vault Referencing Foreign keys:

    remove_index :boxes, [:name, :vault_id]
    remove_index :boxes, :vault_id
    remove_foreign_key :boxes, :vaults
    change_column_null :boxes, :vault_id, true
    rename_column :boxes, :vault_id, :integer_vault_id
    add_column :boxes, :vault_id, :uuid

    # Foreign keys in vaults

    remove_index :vaults, [:owner_type, :owner_id]
    change_column_null :vaults, :owner_id, true
    rename_column :vaults, :owner_id, :integer_owner_id
    add_column :vaults, :owner_id, :uuid
    # add_index :vaults, [:owner_type, :owner_id]

    # primary key change:

    remove_column :vaults, :uuid
    add_column :vaults, :uuid, :uuid, default: 'uuid_generate_v4()', null: false
    rename_column :vaults, :id, :integer_id
    rename_column :vaults, :uuid, :id
    execute 'ALTER TABLE vaults DROP CONSTRAINT IF EXISTS vaults_pkey;'
    execute 'ALTER TABLE vaults ADD PRIMARY KEY (id);'

    execute 'ALTER TABLE ONLY vaults ALTER COLUMN integer_id DROP DEFAULT;'
    change_column_null :vaults, :integer_id, true
    execute 'DROP SEQUENCE IF EXISTS vaults_id_seq'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
