module HelperMethods
  def emailed_addresses
    all_emails.map(&:to).map(&:first)
  end

  def silent_puts
    allow($stdout).to receive(:puts)
  end

  def nested_hash_value(obj, key)
    if obj.respond_to?(:key?) && obj.key?(key)
      obj[key]
    elsif obj.respond_to?(:each)
      r = nil
      obj.find { |*a| r = nested_hash_value(a.last, key) }
      r
    end
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
