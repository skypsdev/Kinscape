module Api
  module V1
    class FamiliesController < BaseController
      def index
        authorize! :read, Family
        @pagy, records = pagy(families_query(
                                [
                                  :chapters,
                                  { cover_attachment: :blob },
                                  { kinships: { avatar_attachment: :blob } }
                                ]
                              ), items: 12)
        response_service.render_collection(
          FamilySerializer,
          records,
          options: {
            include: includes,
            fields: {
              family: FamilySerializer.attributes_to_serialize.keys
            }
          }
        )
      end

      def quick_list
        authorize! :read, Family
        response_service.render_collection(
          FamilySerializer,
          families_query([kinships: { avatar_attachment: :blob }, cover_attachment: :blob]),
          options: {
            include: [:kinships],
            fields: {
              family: [:name, :cover_url, :user_role, :kinships],
              kinship: [:nickname, :avatar_url, :user_id]
            }
          }
        )
      end

      def create
        authorize! :create, Family
        family = ::Families::CreationService.call(current_user, family_create_params)
        response_service.render(FamilySerializer, family, options: { include: includes })
      end

      def show
        authorize! :read, family
        options = { include: [:all_comments] }
        response_service.render(FamilySerializer, family, options: options)
      end

      def update
        authorize! :update, family
        family_updated = ::Families::UpdatingService.call(family, family_update_params)
        response_service.render(FamilySerializer, family_updated, options: { include: includes })
      end

      def destroy
        authorize! :destroy, family
        ::MailerService.call(:community_deleted, params: { family: family, user: current_user })
        family.destroy!
        response_service.render_no_content
      end

      private

      def families_query(includes = {})
        families = Family.default_access.accessible_by(current_ability).includes(includes)
        if params[:query].present?
          families = families.where('LOWER(families.name) LIKE ?', "%#{params[:query].downcase}%")
        end
        families.order('name')
      end

      def family
        @family ||= if params[:showcase].present?
                      families = User.find_by(email: Showcase::USER_EMAIL).families
                      families.find_by(name: Showcase::FAMILY_NAME)
                    else
                      Family.find(params[:id])
                    end
      end

      def family_update_params
        params.permit(:name, :motto, :cover, :description)
      end

      def family_create_params
        params.permit(:name, :motto, :cover, :family_type, :description)
      end
    end
  end
end
