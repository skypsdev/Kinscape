require 'spec_helper'

describe Api::V1::OwnershipTransfersController, type: :controller do
  let(:user) { create :user }
  let!(:family) { create(:family, users: [user]) }

  before { sign_in_as(user) }

  describe '#new' do
    subject(:result) { get :new }

    it 'returns families' do
      expect(result).to be_successful
      expect(result.parsed_body['data'].count).to eq 1
      expect(result.parsed_body['data'].first['id']).to eq family.id
    end
  end

  describe '#create' do
    subject(:result) { post :create, params: params }

    let(:params) do
      {
        family_id: family.id,
        new_admin_id: new_admin.id,
        end_date: Time.current.tomorrow,
        time_zone: 'Europe/Warsaw'
      }
    end
    let(:new_admin) { create :user }
    let!(:family) { create(:family, users: [user, new_admin]) }

    it 'creates an ownership transfer' do
      stub_mandrill
      expect { result }.to change(OwnershipTransfer, :count).by(1)
      expect(result).to be_successful
      expect(OwnershipTransfer.last).to have_attributes(
        family: family,
        new_admin: new_admin,
        old_admin: user,
        expires_at: be_present
      )
      expect(all_emails.map(&:subject)).to contain_exactly("You've Been Asked to Become an Admin")
    end
  end
end
