require 'swagger_helper'

RSpec.describe Api::V1::VaultsController, type: :request do
  let(:user) { create :user }
  let(:id) { user.vault.id }

  path '/api/v1/vaults' do
    parameter name: :query, in: :query, type: :string

    let(:query) { nil }

    let!(:family_1) { create :family, users: [user], name: 'Summer 2008' }
    let!(:family_2) { create :family, users: [user], name: 'Summer 2004' }
    let!(:family_3) { create :family, users: [user], name: 'Summer 2007' }
    let!(:family_4) { create :family, users: [user], name: 'Aloha 2000' }

    get('list vaults') do
      include_context 'cookie'
      tags 'Vault'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data'].pluck('id')).to eq(
            [
              user.vault.id.to_s,
              family_4.vault.id.to_s,
              family_2.vault.id.to_s,
              family_3.vault.id.to_s,
              family_1.vault.id.to_s
            ]
          )
        end
      end

      response(200, 'successful', document: false) do
        let(:query) { 'summer' }

        run_test! do
          expect(response.parsed_body['data'].pluck('id')).to eq(
            [
              family_2.vault.id.to_s,
              family_3.vault.id.to_s,
              family_1.vault.id.to_s
            ]
          )
        end
      end
    end
  end
  path '/api/v1/vaults/{id}' do
    parameter name: :id, in: :path, type: :string

    get('show vault') do
      include_context 'cookie'
      tags 'Vault'

      parameter name: :showcase, in: :query, type: :boolean
      let(:showcase) { nil }

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data']['id']).to eq(id.to_s)
          expect(response.parsed_body['data']['attributes']['name']).to eq('My Vault')
        end
      end
    end
  end
end
