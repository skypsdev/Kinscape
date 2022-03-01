require 'filestack_config'

module Api
  module V1
    module Vaults
      class AttachmentsController < BaseController
        def create
          authorize! :add_boxes_to_vault, vault
          attachment = Attachments::CreationService.call(
            vault: vault,
            params: create_params,
            current_user: current_user
          )
          response_service.render(VaultItemSerializer, attachment)
        end

        def update
          attachment = ActiveStorage::Attachment.find(params[:id])
          authorize! :update, attachment
          attachment.update(update_params)
          response_service.render(VaultItemSerializer, attachment)
        end

        def move
          attachments.all? { |attachment| authorize! :edit, attachment }
          Attachments::MovingService.call(vault: vault, attachments: attachments, params: params)
          response_service.render_no_content
        end

        def copy
          attachments.all? { |attachment| authorize! :read, attachment }
          new_vault = Vault.find(params[:new_vault_id])
          authorize! :add_boxes_to_vault, new_vault
          Attachments::CopyingService.new(
            vault: vault,
            attachments: attachments,
            new_vault: new_vault,
            current_user: current_user,
            params: params
          ).call
          response_service.render_no_content
        end

        def upload_config
          # TODO: remove endpoint
          render json: FilestackConfig.upload
        end

        private

        def create_params
          params.permit(:box_id, :file)
        end

        def share_params
          params.permit(:box_id, :new_vault_id, :ids)
        end

        def update_params
          params.permit(:title)
        end

        def vault
          @vault ||= Vault.find(params[:vault_id])
        end

        def attachments
          @attachments ||= ActiveStorage::Attachment.includes(:blob).where(id: params[:ids], record: vault)
        end
      end
    end
  end
end
