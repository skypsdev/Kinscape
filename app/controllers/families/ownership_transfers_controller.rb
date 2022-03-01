module Families
  class OwnershipTransfersController < ApplicationController
    skip_before_action :require_login, only: [:show]
    before_action :find_ownership_transfer

    def show
      return redirect_to '/communities?expire=true' if @ownership_transfer.expires_at < Time.current

      sign_in @ownership_transfer.new_admin
    end

    def update
      ::Families::OwnershipService.call(@ownership_transfer)
      return flash_error_and_redirect unless @ownership_transfer.status_accepted?

      # Temp. remove payment feature
      # Billing::SubscriptionService.subscribe(@ownership_transfer.new_admin)

      flash[:success] = t('transfer.update.flash.success', family_name: @ownership_transfer.family.name)
      redirect_to families_path
    end

    def decline_invitation
      @ownership_transfer.update!(status: 'declined')
      ::MailerService.call(:notify_previous_admin, params: { ownership_transfer: @ownership_transfer })
      redirect_to families_path
    end

    private

    def flash_error_and_redirect
      flash[:error] = t('transfer.update.flash.error')
      redirect_to root_path
    end

    def find_ownership_transfer
      @ownership_transfer ||= OwnershipTransfer.status_pending.find_by(id: params[:id])
      flash_error_and_redirect if @ownership_transfer.nil?
    end
  end
end
