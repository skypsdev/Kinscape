class CreateRegistrationCode < ActiveRecord::Migration[6.1]
  def change
    create_table :registration_codes do |t|
      t.string :code, limit: 5, null: false

      t.timestamps
    end
  end
end
