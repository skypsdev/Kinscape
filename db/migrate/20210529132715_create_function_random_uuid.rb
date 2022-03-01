class CreateFunctionRandomUuid < ActiveRecord::Migration[6.0]
  def change
    create_function :random_uuid_bigint
  end
end
