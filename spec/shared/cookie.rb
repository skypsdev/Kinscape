shared_context 'cookie' do
  security [cookie: []]
  let(:token) { user.remember_token }
  let(:cookie) { "remember_token_test=#{token};" }
  it_behaves_like 'invalid cookie'
end

shared_context 'invalid cookie' do
  response(401, 'unauthorized') do
    let(:cookie) { nil }
    run_test!
  end
end
