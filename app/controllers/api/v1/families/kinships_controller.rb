module Api
  module V1
    module Families
      class KinshipsController < BaseController
        def index
          authorize! :read, Kinship
          @pagy, kinships = pagy(sorted_kinships, items: 12)

          response_service.render_collection(KinshipSerializer, kinships, options: { include: includes })
        end

        private

        def sorted_kinships
          Kinship.accessible_by(current_ability)
                 .where(family: family)
                 .includes([:family, :user, :rich_text_rich_profile, :media_avatar, :avatar_attachment, :chapters])
                 .order(Arel.sql("users.id = #{current_user.id} DESC"))
                 .order(Arel.sql("users.id = #{family.admin_kinship.user_id} DESC"))
                 .order('users.first_name ASC')
        end

        def family
          current_user.families.find_by_uid!(params[:family_id])
        end
      end
    end
  end
end
