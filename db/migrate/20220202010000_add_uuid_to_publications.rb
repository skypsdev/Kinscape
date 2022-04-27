class AddUuidToPublications < ActiveRecord::Migration[6.1]
  def up
    add_column :publications, :uuid, :uuid, default: "uuid_generate_v4()", null: false
    rename_column :publications, :id, :integer_id
    rename_column :publications, :uuid, :id
    execute "ALTER TABLE publications DROP CONSTRAINT IF EXISTS publications_pkey;"
    execute "ALTER TABLE publications DROP CONSTRAINT IF EXISTS shares_pkey;" # staging and production
    execute "ALTER TABLE publications ADD PRIMARY KEY (id);"

    execute "ALTER TABLE ONLY publications ALTER COLUMN integer_id DROP DEFAULT;"
    change_column_null :publications, :integer_id, true
    execute "DROP SEQUENCE IF EXISTS publications_id_seq"

    add_index :publications, :created_at

    remove_index :comments, :publication_id
    change_column_null :comments, :publication_id, true
    rename_column :comments, :publication_id, :integer_publication_id
    add_column :comments, :publication_id, :uuid
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
