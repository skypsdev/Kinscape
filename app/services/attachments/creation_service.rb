module Attachments
  class CreationService < ApplicationService
    def initialize(vault:, params:, current_user:)
      @vault = vault
      @params = params
      @current_user = current_user
    end

    def call
      ActiveRecord::Base.transaction do
        blob.attachments.create!(
          name: 'files',
          record: vault,
          box: box,
          family: family,
          user: current_user
        )
      end
    end

    private

    def blob
      @blob ||= ActiveStorage::Blob.find_signed!(params[:file])
    end

    def box
      @box ||= vault.boxes.find(params[:box_id]) if params[:box_id]
    end

    def family
      vault.owner if vault.owner_type == 'Family'
    end

    attr_reader :vault, :params, :current_user
  end
end
