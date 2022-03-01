module ApplicationHelper
  def background_image_css(url)
    url.blank? ? '' : "background-image: url(#{url});"
  end
end
