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
        authorize! :read, vault
        response_service.render(VaultSerializer, vault)
      end

      private

      def vault
        @vault = if params[:showcase].present?
                   User.find_by(email: Showcase::USER_EMAIL).vault
                 else
                   Vault.find(params[:id])
                 end
      end

      def all_vaults
        Vault.where(owner_type: 'User', owner_id: current_user.id).or(
          Vault.where(owner_type: 'Family', owner_id: current_user.families.ids)
        )
      end
    end
  end
end
