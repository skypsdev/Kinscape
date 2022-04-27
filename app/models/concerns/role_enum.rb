module RoleEnum
  extend ActiveSupport::Concern

  included do
    enum role: {
      admin: 'admin',
      co_admin: 'co_admin',
      member: 'member',
      offline_member: 'offline_member',
      guest: 'guest'
    }, _prefix: true
  end
end
