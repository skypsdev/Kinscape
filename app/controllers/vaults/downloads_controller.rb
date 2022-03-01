module Vaults
  class DownloadsController < ApplicationController
    def show
      authorize! :read, vault
      attachments = ActiveStorage::Attachment.where(id: params[:ids], record: vault)
      return redirect_to file_url(attachments.first) if attachments.size == 1

      send_file(
        ::Vaults::GenerateZipService.call(attachments, vault),
        type: 'application/zip',
        filename: "vault-files-#{vault.owner.name.parameterize}.zip"
      )
    end

    private

    def vault
      @vault ||= Vault.find(params[:vault_id])
    end

    def file_url(attachment)
      attachment.url(
        expires_in: 30.seconds,
        disposition: :attachment,
        filename: attachment.title || attachment.filename.to_s
      )
    end
  end
end
