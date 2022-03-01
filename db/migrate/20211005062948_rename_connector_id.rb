class RenameConnectorId < ActiveRecord::Migration[6.1]
  def change
    rename_column :families, :connector_id, :legacy_connector_id
  end
end
