module Api
  module V1
    class CategoriesController < BaseController
      def index
        authorize! :read, Publication
        tags = ActsAsTaggableOn::Tag
               .joins(:taggings)
               .where(taggings: { taggable_type: 'Story', taggable_id: all_publications&.pluck(:story_id) })
               .distinct
               .order(updated_at: :desc)

        all_tags = tags.map { |tag| { text: tag.name, number: tag.taggings_count } }
        render json: { data: all_tags }
      end

      private

      def all_publications
        @all_publications ||= Publication.accessible_by(current_ability)
      end
    end
  end
end
