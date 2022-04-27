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

      return if errors.any?

      ActiveRecord::Base.transaction do
        attachments.map do |attachment|
          existing_attachments = attachment.blob.attachments.where(record: new_vault)
          copy_number = lowest_available(existing_attachments.pluck(:copy_number))
          attachment.blob.attachments.create!(
            name: 'files',
            record: new_vault,
            box: box,
            family_id: attachment.family_id,
            user_id: attachment.user_id,
            copy_number: copy_number,
            title: title(attachment.blob, copy_number)
          )
        end
      end
    end

    private

    attr_reader :vault, :attachments, :new_vault, :current_user, :params

    def box
      @box ||= new_vault.boxes.find(params[:box_id]) if params[:box_id]
    end

    def title(blob, copy_number)
      return if copy_number.zero?

      blob.filename.base + "(#{copy_number})"
    end

    def lowest_available(ids_array)
      return 0 if ids_array.blank?

      ids_array.sort.filter_map.with_index do |id, index|
        break index if index != id
      end.presence || ids_array.max + 1
    end
  end
end
