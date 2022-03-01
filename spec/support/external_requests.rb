require 'pry'

module ExternalRequests
  def stub_mandrill
    stub_request(
      :post,
      'https://mandrillapp.com/api/1.0/templates/render.json'
    ).to_return(body: { html: 'hello' }.to_json)
  end

  def stub_image_convert(base_url)
    requests = {}

    Image.formats.each do |image_format, params|
      fit_param    = "fit=#{params[:fit]}&"       if params[:fit]
      height_param = "height=#{params[:height]}&" if params[:height]

      regex = %r{
                #{base_url}/convert\?
                #{fit_param}
                #{height_param}
                key=#{Global.filepicker.api_key}&
                policy=[a-zA-z0-9=]*&
                rotate=exif&
                signature=[a-z0-9]*&
                storePath=/images/#{image_format}/&
                width=#{params[:width]}
                }x
      requests[image_format] = stub_convert(regex, image_format)
    end

    requests
  end

  def stub_avatar_convert(base_url)
    requests = {}
    Avatar.formats.each do |image_format, params|
      regex = %r{
                #{base_url}/convert\?
                align=faces&
                fit=clip&
                height=#{params[:height]}&
                key=#{Global.filepicker.api_key}&
                policy=[a-zA-z0-9]*&
                rotate=exif&
                signature=[a-z0-9]*&
                storePath=/avatars/#{image_format}/&
                width=#{params[:width]}
                }x
      requests[image_format] = stub_convert(regex, image_format)
    end
    requests
  end

  def stub_cover_image_convert(base_url)
    requests = {}

    CoverImage.formats.each do |image_format, params|
      regex = %r{
                #{base_url}/convert\?
                height=#{params[:height]}&
                key=#{Global.filepicker.api_key}&
                policy=[a-zA-z0-9]*&
                rotate=exif&
                signature=[a-z0-9]*&
                storePath=/cover_images/#{image_format}/&
                width=#{params[:width]}
                }x
      requests[image_format] = stub_convert(regex, image_format)
    end

    requests
  end

  private

  def stub_convert(regex, size)
    stub_request(:post, regex)
      .to_return(
        status: 200,
        body: "{
          \"container\": \"kinscape-test\",
          \"url\": \"https://www.placehold.it/api/file/FfxPs5GoSFSjaiIS6RKL\",
          \"height\": null,
          \"width\": \"1280\",
          \"key\": \"images/#{size}/test-image.jpg\",
          \"filename\": \"test-image.jpg\",
          \"type\": \"image/jpeg\",
          \"size\": 27892}",
        headers: {}
      )
  end
end

RSpec.configure do |config|
  config.before do
    stub_request(:get, /placehold.it/)
      .to_return(status: 200, body: '', headers: {})

    stub_request(:post, /api.airbrake.io/)
      .with(headers: { 'Accept' => 'text/xml, application/xml',
                       'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: '', headers: {})

    stub_image_convert('placehold.it/\d+x')
    stub_avatar_convert('placehold.it/\d+x')
    stub_cover_image_convert('placehold.it/\d+x')

    stub_request(:put, /s3-us-west-2.amazonaws.com/)
      .to_return(status: 200, body: '', headers: {})
  end
end
