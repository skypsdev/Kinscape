module ExternalRequests
  def stub_mandrill
    stub_request(
      :post,
      'https://mandrillapp.com/api/1.0/templates/render.json'
    ).to_return(body: { html: 'hello' }.to_json)
  end
end
