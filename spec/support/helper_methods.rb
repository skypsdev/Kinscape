module HelperMethods
  def emailed_addresses
    all_emails.map(&:to).map(&:first)
  end

  def silent_puts
    allow($stdout).to receive(:puts)
  end

  def create_file_blob(params = {})
    ActiveStorage::Blob.create_and_upload!(
      io: file_fixture(params[:filename] || 'image.jpg').open,
      filename: params[:filename] || 'image.jpg',
      content_type: params[:content_type] || 'image/jpeg',
      metadata: params[:metadata]
    )
  end
end
