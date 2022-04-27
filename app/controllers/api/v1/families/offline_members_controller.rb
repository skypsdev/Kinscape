module Api
  module V1
    module Families
      class OfflineMembersController < BaseController
        def create
          authorize! :manage, family
          offline_member = family.offline_members.new(
            **kinship_params,
            role: 'offline_member',
            inviter: current_user
          )
          ::Invitations::NotificationService.call(family, offline_member: offline_member) if offline_member.save
          response_service.render(KinshipSerializer, offline_member)
        end

        def update
          offline_member = Kinship.find(params[:id])
          authorize! :manage, offline_member
          offline_member.update kinship_params
          response_service.render(KinshipSerializer, offline_member)
        end

        private

        def kinship_params
          params.permit(
            :avatar,
            :nickname,
            :description,
            profile_attrs: {}
          )
        end

        def family
          Family.find(params[:family_id])
        end
      end
    end
  end
end
