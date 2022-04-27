module Vaults
  class GenerateZipService < ApplicationService
    def initialize(files, vault)
      @files = files
      @download_dir_path = Rails.root.join('tmp', 'files', "vault-#{vault.id}")
      @zip_file = Tempfile.new
    end

    def call
      FileUtils.mkdir_p(download_dir_path) unless Dir.exist?(download_dir_path)
      DownloadFilesService.call(documents: documents, download_dir_path: download_dir_path)
      CompressFilesService.call(zip_file: zip_file, download_dir_path: download_dir_path)
      FileUtils.rm_rf(download_dir_path, secure: true)
      zip_file.path
    end

    private

    def documents
      files.map do |file|
        {
          url: Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true),
          filename: file.title || file.filename.to_s
        }
      end
    end

    attr_reader :files, :download_dir_path, :zip_file
  end
end
