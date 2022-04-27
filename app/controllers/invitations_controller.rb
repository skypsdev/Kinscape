class InvitationsController < ApplicationController
  skip_before_action :require_login

  def decline
    # TODO: revisit before merging to master
    invitation = Invitation.find_by(id: params[:id])
    return redirect_to "/communities/#{invitation.family.id}/?accepted=true" if invitation&.accepted_at.present?

    invitation&.destroy!
    sign_out if @user
    flash[:success] = t('families.flash.alert.decline')
    redirect_to root_path
  end
end
