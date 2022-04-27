module Api
  module V1
    module Publications
      class FamiliesController < BaseController
        def index
          authorize! :read, publication
          response_service.render_collection(
            FamilySerializer,
            families_query,
            options: {
              fields: { family: [:name, :cover_url] }
            }
          )
        end

        private

        def publication
          @story ||= Publication.find(params[:publication_id])
        end

        def families_query
          Family
            .accessible_by(current_ability)
            .where.not(id: publication.story.publications.pluck(:family_id))
            .joins(:kinships)
            .where(kinships: { user_id: current_user.id })
            .where.not(kinships: { role: :guest })
            .order(
              Arel.sql(<<~SQL.squish)
                CASE families.id
                  WHEN '#{current_user.personal_family.id}' THEN 1
                  ELSE 2
                END
                ASC
              SQL
            ).order('families.name ASC')
        end
      end
    end
  end
end
