module Attachments
  class CopyingService
    attr_reader :errors

    def initialize(vault:, attachments:, new_vault:, current_user:, params:)
      @vault = vault
      @attachments = attachments
      @new_vault = new_vault
      @current_user = current_user
      @params = params
      @errors = []
    end

    def call
      raise ActiveRecord::RecordNotFound if attachments.size != params[:ids].size

      errors << I18n.t('copying.errors.different_vaults') if attachments.pluck(:record_id).uniq.size != 1
      errors << I18n.t('copying.errors.same_vault') if vault == new_vault

      return if errors.any?

      Attachment.transaction do
        attachments.map do |attachment|
          blob = attachment.blob
          next if blob.attachments.find_by(record: new_vault)

          blob.attachments.create!(
            name: 'files',
            record: new_vault,
            box: box,
            family_id: attachment.family_id,
            user_id: attachment.user_id
          )
        end
      end
    end

    private

    attr_reader :vault, :attachments, :new_vault, :current_user, :params

    def box
      @box ||= new_vault.boxes.find(params[:box_id]) if params[:box_id]
    end
  end
end
