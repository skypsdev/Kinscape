desc 'Migrates wards to offline members'
task offline_members: :environment do
  ActiveRecord::Base.transaction do
    users = User.where.not(caretaker_id: nil)
    users.each do |user|
      # on production
      # irb> User.where.not(caretaker_id: nil).includes(:kinships).map { |user| user.kinships.count }.uniq
      # => [1, 0]
      kinship = user.kinships.first
      if kinship.nil?
        user.destroy!
        next
      end

      user.save validation: false

      kinship.update!(
        nickname: user.name,
        birth_date: user.birth_date,
        user_id: nil,
        email: user.email # temporary backup
      )
    end
  end
end
