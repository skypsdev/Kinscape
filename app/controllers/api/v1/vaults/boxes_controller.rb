module Api
  module V1
    module Vaults
      class BoxesController < BaseController
        def show
          authorize! :read, box
          response_service.render(VaultItemSerializer, box)
        end

        def create
          authorize! :add_boxes_to_vault, vault
          box = vault.boxes.create box_params
          response_service.render(VaultItemSerializer, box)
        end

        def update
          authorize! :update, box
          box.update box_params
          response_service.render(VaultItemSerializer, box)
        end

        private

        def vault
          @vault ||= Vault.find params[:vault_id]
        end

        def box
          @box ||= Box.find params[:id]
        end

        def box_params
          params.permit(:name, :parent_box_id)
        end
      end
    end
  end
end
