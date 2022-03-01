require 'zip'

class CompressFilesService < ApplicationService
  def initialize(zip_file:, download_dir_path:)
    @zip_file = zip_file
    @download_dir_path = download_dir_path
  end

  def call
    Zip::File.open(zip_file.path, Zip::File::CREATE) do |zip|
      entries = Dir.entries(download_dir_path) - %w[. ..]
      entries.each { |entry| zip.add(entry, File.join(download_dir_path, entry)) }
    end
  end

  private

  attr_reader :download_dir_path, :zip_dir_name, :zip_file
end
