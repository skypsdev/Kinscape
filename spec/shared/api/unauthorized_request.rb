shared_examples 'unauthorized request' do |method, path|
  let(:parsed_body) { JSON.parse(response.body) }

  before { send(method, path) }

  it { expect(parsed_body['message']).to eq('unauthorized') }
end

shared_examples 'unauthorized request - controller' do |method, action, params = {}|
  before { send(method, action, params: params) }

  it do
    expect(response.parsed_body['message']).to eq('unauthorized')
  end
end

shared_examples 'unauthorized - subscription missing' do
  response(401, 'unauthorized') do
    run_test!
  end
end
