class AddUuidToTaggings < ActiveRecord::Migration[6.1]
  def up
    remove_column :taggings, :tenant, :string, limit: 128
    remove_index :taggings, ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    remove_index :taggings, ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    remove_index :taggings, ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    remove_index :taggings, ["taggable_id"]
    remove_index :taggings, ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    remove_index :taggings, ["tagger_id"]

    rename_column :taggings, :taggable_id, :integer_taggable_id
    add_column :taggings, :taggable_id, :uuid
    rename_column :taggings, :tagger_id, :integer_tagger_id
    add_column :taggings, :tagger_id, :uuid
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
