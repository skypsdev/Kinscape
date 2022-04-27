module Showcase
  USER_EMAIL = 'kintest+melissa+jones@kinscape.com'.freeze
  FAMILY_NAME = 'Jones Family Adventures'.freeze
  extend ActiveSupport::Concern

  included do
    validate :showcase_change
    before_destroy :check_showcase
  end

  def showcase_change
    errors.add(:showcase, '- updating this record is not allowed') if changed? && showcase? && persisted?
  end

  def check_showcase
    raise 'Deleting this record is not allowed' if showcase?
  end
end
