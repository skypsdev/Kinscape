class KinshipNicknameRequired < ActiveRecord::Migration[6.1]
  def change
    Kinship.includes(:user).where(nickname: [nil, '']).find_each do |kinship|
      kinship.update!(nickname: kinship.user.name)
    end

    change_column_null :kinships, :nickname, false
  end
end
