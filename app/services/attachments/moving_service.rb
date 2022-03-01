module Attachments
  class MovingService < ApplicationService
    def initialize(vault:, attachments:, params:)
      @vault = vault
      @attachments = attachments
      @params = params
    end

    def call
      raise ActiveRecord::RecordNotFound if attachments.size != params[:ids].size

      attachments.update_all(box_id: box&.id)
    end

    private

    attr_reader :params, :attachments, :vault

    def box
      @box ||= vault.boxes.find(params[:box_id]) if params[:box_id]
    end
  end
end
