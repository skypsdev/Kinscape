module Families
  class OwnershipService < ApplicationService
    def initialize(ownership_transfer)
      @ownership_transfer = ownership_transfer
      @old_admin = ownership_transfer.old_admin
      @family = ownership_transfer.family
      @new_admin = ownership_transfer.new_admin
    end

    def call
      return ownership_transfer unless old_admin&.ability&.can?(:manage, family)
      return ownership_transfer unless family&.users&.include?(new_admin)
      return ownership_transfer unless new_admin.role_for(family).in?(%w[member co_admin])

      ActiveRecord::Base.transaction do
        family.kinship_for(old_admin).update!(role: 'member')
        family.kinship_for(new_admin).update!(role: 'admin')
        ownership_transfer.update!(status: 'accepted')
        ::MailerService.call(
          :admin_transfer_accepted,
          params: { ownership_transfer: ownership_transfer }
        )
      end
      ownership_transfer
    rescue StandardError
      ownership_transfer
    end

    private

    attr_reader :old_admin, :family, :new_admin, :ownership_transfer
  end
end
