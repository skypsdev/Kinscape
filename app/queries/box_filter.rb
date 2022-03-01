class BoxFilter < ApplicationQuery
  def initialize(params:)
    @boxes = Box.where(vault_id: params[:id], parent_box_id: params[:box_id].presence)
    @params = params
  end

  def call
    query_filter
    sort_by
  end

  private

  attr_reader :params

  def query_filter
    return if params[:query].blank?

    @boxes = @boxes.where('LOWER(name) LIKE ?', "%#{params[:query].downcase}%")
  end

  def sort_by
    direction = params[:sort_direction].presence || 'DESC'
    case params[:sort_by]
    when 'name'
      @boxes.order("name #{direction}")
    else
      @boxes.order("created_at #{direction}")
    end
  end
end
