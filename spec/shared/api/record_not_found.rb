shared_examples 'record not found' do |method, path|
  before { send(method, path) }

  it { expect(response).to have_http_status :not_found }
end
