class PublicationFilter < ApplicationQuery
  def initialize(publications:, params:, current_user:, includes: {})
    @publications = publications.joins(:story).includes(includes)
    @current_user = current_user
    @params = params
  end

  def call
    family_filter
    visibility_filter
    category_filter
    author_filter
    query_filter
    sort_by
  end

  private

  attr_reader :params, :current_user

  def family_filter
    return if params[:family_id].blank?

    family = Family.find_by_uid(params[:family_id])
    return unless family

    @publications = @publications.where(family_id: family.id)
  end

  def visibility_filter
    @publications = case params[:publication_visibility]
                    when 'private_stories'
                      @publications.private_type
                                   .where.not(id: @publications.private_type.joins(:shared_publications).ids)
                    when 'shared_stories'
                      @publications.not_private_type.where(stories: { user_id: current_user.id })
                    else
                      @publications.not_private_type
                    end
  end

  def category_filter
    return if params[:categories].blank?

    @publications = @publications.where('stories.categories @> ARRAY[?]::varchar[]', params[:categories])
  end

  def author_filter
    return if params[:author_id].blank?

    @publications = @publications.where(stories: { user_id: params[:author_id] })
  end

  def query_filter
    return if params[:query].blank?

    @publications = @publications.where('LOWER(stories.title) LIKE ?', "%#{params[:query].downcase}%").reorder(nil)
  end

  def sort_by
    direction = params[:sort_direction].presence || 'DESC'
    case params[:sort_by]
    when 'created_at'
      @publications.order("stories.created_at #{direction}, publications.created_at #{direction}")
    when 'title'
      @publications.order("stories.title #{direction}")
    when 'updated_at'
      @publications.order("stories.updated_at #{direction}, publications.updated_at #{direction}")
    else
      @publications.order('stories.updated_at DESC')
    end
  end
end
