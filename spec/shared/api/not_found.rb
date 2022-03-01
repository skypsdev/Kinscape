shared_examples 'not found resource' do |method, path|
  let(:user) { create :user }

  before do
    sign_in_as user
    send(method, path)
  end

  it do
    expect(response).to have_http_status :not_found
    expect(response.parsed_body['message']).to eq 'not found'
  end
end
