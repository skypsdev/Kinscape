module Api
  module V1
    module Messages
      class RecipientsController < BaseController
        def index
          authorize! :read, Family
          response_service.render_collection(
            FamilySerializer,
            families_query,
            options: {
              include: [:kinships],
              fields: { family: [:name, :cover_url, :kinships], kinship: [:nickname, :avatar_url, :user_id] },
              params: { skip_current_user: true }
            }
          )
        end

        private

        def families_query
          families = Family.accessible_by(current_ability).where.not(id: current_user.private_family.id)
          families.order('name')
        end
      end
    end
  end
end
