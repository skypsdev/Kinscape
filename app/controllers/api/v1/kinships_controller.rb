module Api
  module V1
    class KinshipsController < BaseController
      def show
        kinship = Kinship.includes(includes).find(params[:id])
        authorize! :read, kinship
        options = { include: [:all_comments] }
        response_service.render(KinshipSerializer, kinship, options: options)
      end

      def show_by_family
        kinship = if params[:showcase].present?
                    Kinship.joins(:family).find_by(
                      families: { name: Showcase::FAMILY_NAME },
                      user_id: User.find_by(email: Showcase::USER_EMAIL).id
                    )
                  else
                    current_user.all_kinships.find_by(family_id: params[:family_id])
                  end
        authorize! :read, kinship
        response_service.render(KinshipSerializer, kinship, options: { include: includes })
      end

      def update
        kinship = Kinship.find params[:id]
        authorize! :update, kinship
        kinship.update(kinship_params)
        response_service.render(KinshipSerializer, kinship)
      end

      def destroy
        kinship = Kinship.find(params[:id])
        authorize! :destroy, kinship
        ::MailerService.call(:removed_from_community, params: { kinship: kinship, user: current_user })
        stories = kinship.family.stories.where(user: kinship.user)
        Publication.where(family: kinship.family, story: stories).destroy_all
        kinship.destroy!
        response_service.render_no_content
      end

      def kinship_data
        family = Family.find(params[:family_id])
        kinship = family.kinships.find_by(user_id: params[:user_id])
        authorize! :read, kinship
        response_service.render(KinshipSerializer, kinship, options: { include: includes })
      end

      def notify
        kinship = Kinship.find(params[:id])
        authorize! :read, kinship
        kinship.family.kinships.where.not(user_id: current_user.id).each do |member|
          ::Kinships::NotificationService.notify_members(member, current_user, params[:changed_attr])
        end

        response_service.render_no_content
      end

      private

      def kinship_params
        params.permit(
          :avatar,
          :nickname,
          profile_attrs: {}
        )
      end
    end
  end
end
