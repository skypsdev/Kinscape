module Api
  module V1
    module Families
      class KinshipsController < BaseController
        def index
          authorize! :read, family
          @pagy, kinships = pagy(sorted_kinships, items: 12)

          response_service.render_collection(KinshipSerializer, kinships, options: { include: includes })
        end

        private

        def sorted_kinships
          Kinship.accessible_by(current_ability)
                 .where(family: family)
                 .includes([:family, :inviter, { avatar_attachment: :blob }])
                 .order(
                   Arel.sql(<<~SQL.squish)
                     CASE kinships.user_id
                       WHEN '#{current_user.id}' THEN 1
                       WHEN '#{family.admin_kinship.user_id}' THEN 2
                       ELSE 3
                     END
                     ASC
                   SQL
                 )
                 .order('kinships.nickname ASC')
        end

        def family
          Family.find(params[:family_id])
        end
      end
    end
  end
end
