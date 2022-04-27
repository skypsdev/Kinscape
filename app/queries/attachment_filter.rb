class AttachmentFilter < ApplicationQuery
  def initialize(params:)
    @params = params
    @attachments = ActiveStorage::Attachment.joins(:blob)
                                            .includes(user: :kinships)
                                            .where(
                                              record_type: 'Vault',
                                              record_id: params[:vault_id],
                                              box_id: params[:box_id].presence
                                            )
  end

  def call
    query_filter
    sort_by
  end

  private

  attr_reader :params

  def query_filter
    return if params[:query].blank?

    query = params[:query].downcase
    @attachments = @attachments.where(
      "LOWER(COALESCE(active_storage_attachments.title, active_storage_blobs.filename)) LIKE '%#{query}%'"
    )
  end

  def sort_by
    direction = params[:sort_direction].presence || 'DESC'
    case params[:sort_by]
    when 'title'
      @attachments.order(
        Arel.sql("COALESCE(active_storage_attachments.title, active_storage_blobs.filename) #{direction}")
      )
    when 'content_type'
      @attachments.order("active_storage_blobs.content_type #{direction}")
    else
      @attachments.order("active_storage_attachments.created_at #{direction}")
    end
  end
end
