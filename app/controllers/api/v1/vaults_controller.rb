module Api
  module V1
    class VaultsController < BaseController
      def index
        vaults = all_vaults
        vaults = vaults.where('LOWER(name) LIKE ?', "%#{params[:query].downcase}%") if params[:query].present?
        vaults = vaults.left_joins(:family).order('vaults.owner_type DESC, families.name ASC')
        response_service.render_collection(VaultSerializer, vaults)
      end

      def show
        vault = Vault.find(params[:id])
        authorize! :read, vault
        @pagy, records = pagy_array(boxes + attachments, items: params[:per_page].presence || 10)
        response_service.render_collection(VaultItemSerializer, records)
      end

      private

      def all_vaults
        Vault.where(owner_type: 'User', owner_id: current_user.id).or(
          Vault.where(owner_type: 'Family', owner_id: current_user.families.ids)
        )
      end

      def filter_params
        params.permit(:query, :sort_direction, :sort_by, :box_id, :id)
      end

      def boxes
        @boxes ||= BoxFilter.call(params: filter_params)
      end

      def attachments
        condition = ActiveModel::Type::Boolean.new.cast(params[:only_boxes])
        @attachments ||= condition ? [] : AttachmentFilter.call(params: filter_params)
      end
    end
  end
end
