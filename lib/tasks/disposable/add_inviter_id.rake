desc 'Fill inviter id in kinships'
task add_inviter_id: :environment do
  ActiveRecord::Base.transaction do
    Kinship.includes(family: :admin).find_each do |kinship|
      next if kinship.role_admin?

      kinship.update!(inviter_id: kinship.family.admin.id)
    end
  end
end
