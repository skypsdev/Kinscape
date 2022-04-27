ActiveStorage::DiskController.class_eval do
  def acceptable_content?(token)
    (token[:content_type] == request.content_mime_type ||
      token[:content_type].split(';').first == request.content_mime_type) &&
      token[:content_length] == request.content_length
  end
end
