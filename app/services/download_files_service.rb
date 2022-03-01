require 'open-uri'

class DownloadFilesService < ApplicationService
  def initialize(documents:, download_dir_path:)
    @documents = documents
    @download_dir_path = download_dir_path
  end

  def call
    documents.each do |document|
      File.open(File.join(download_dir_path, document[:filename]), 'wb') do |file|
        file << URI.parse(document[:url]).open.read
      end
    rescue
      next
    end
  end

  private

  attr_reader :documents, :download_dir_path
end
