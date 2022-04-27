module AccessEnum
  extend ActiveSupport::Concern

  included do
    enum access_type: {
      default: 'default',
      personal: 'personal',
      private: 'private'
    }, _suffix: :access
  end
end
