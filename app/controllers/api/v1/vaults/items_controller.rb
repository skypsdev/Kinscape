module Api
  module V1
    module Vaults
      class ItemsController < BaseController
        def index
          authorize! :read, vault
          @pagy, records = pagy_array(boxes + attachments, items: params[:per_page].presence || 10)
          response_service.render_collection(VaultItemSerializer, records)
        end

        def destroy
          return response_service.render_forbidden(I18n.t('vaults.items.child_boxes')) if child_boxes.present?

          boxes_to_destroy.each { |box| authorize! :destroy, box }
          attachments_to_destroy.each { |attachment| authorize! :destroy, attachment }
          attachments_to_destroy.destroy_all
          boxes_to_destroy.destroy_all
          response_service.render_no_content
        end

        private

        def filter_params
          if params[:showcase].present?
            { vault_id: vault.id }
          else
            params.permit(:query, :sort_direction, :sort_by, :box_id, :vault_id)
          end
        end

        def vault
          @vault = if params[:showcase].presence.nil?
                     Vault.find(params[:vault_id])
                   elsif params[:showcase_family].present?
                     showcase_user.all_families.find_by(name: Showcase::FAMILY_NAME).vault
                   else
                     showcase_user.vault
                   end
        end

        def showcase_user
          @showcase_user ||= User.find_by(email: Showcase::USER_EMAIL)
        end

        def boxes
          @boxes ||= BoxFilter.call(params: filter_params)
        end

        def attachments
          condition = ActiveModel::Type::Boolean.new.cast(params[:only_boxes])
          @attachments ||= condition ? [] : AttachmentFilter.call(params: filter_params)
        end

        def boxes_to_destroy
          @boxes_to_destroy ||= Box.where(id: params[:boxes_ids])
        end

        def child_boxes
          @child_boxes ||= Box.where(parent_box_id: boxes_to_destroy.ids)
        end

        def attachments_to_destroy
          @attachments_to_destroy ||= ActiveStorage::Attachment.where(id: params[:files_ids]).or(
            ActiveStorage::Attachment.where(box_id: params[:boxes_ids]).where.not(box_id: nil)
          )
        end
      end
    end
  end
end
