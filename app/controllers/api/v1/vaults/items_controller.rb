module Api
  module V1
    module Vaults
      class ItemsController < BaseController
        def destroy
          return response_service.render_forbidden(I18n.t('vaults.items.child_boxes')) if child_boxes.present?

          attachments.each { |attachment| authorize! :destroy, attachment }
          attachments.destroy_all
          boxes.destroy_all
          response_service.render_no_content
        end

        private

        def permitted_params
          params.permit(:boxes_ids, :files_ids)
        end

        def vault
          @vault ||= Vault.find(params[:vault_id])
        end

        def boxes
          @boxes ||= Box.accessible_by(current_ability, :destroy).where(id: params[:boxes_ids])
        end

        def child_boxes
          @child_boxes ||= Box.where(parent_box_id: boxes.ids)
        end

        def attachments
          @attachments ||= ActiveStorage::Attachment.where(id: params[:files_ids]).or(
            ActiveStorage::Attachment.where(box_id: params[:boxes_ids]).where.not(box_id: nil)
          )
        end
      end
    end
  end
end
