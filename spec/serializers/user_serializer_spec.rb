require 'spec_helper'

describe UserSerializer do
  subject(:result) { described_class.new(user.reload, options).serializable_hash }

  let(:user) { create(:user) }
  let(:options) do
    { params: { current_user: user },
      include: [:families],
      fields: {
        user: [:name, :families],
        family: [:name, :motto]
      } }
  end

  before { create(:family, users: [user]) }

  it 'not include real family id' do
    expect(result[:data][:attributes].keys).to contain_exactly(:name)
    expect(result[:data][:relationships].keys).to contain_exactly(:families)
    expect(result[:included].first[:attributes].keys).to contain_exactly(:name, :motto)
  end
end
