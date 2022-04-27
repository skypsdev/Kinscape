class KinshipNicknameRequired < ActiveRecord::Migration[6.1]
  def change
    change_column_null :kinships, :nickname, false
  end
end
