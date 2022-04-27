require 'swagger_helper'

RSpec.describe Api::V1::FamiliesController, type: :request do
  let(:user) { create :user }
  let!(:family) { create(:family, users: [user], name: 'Z-last') }
  let!(:family_1) { create :family, name: 'Purrkins', users: [user] }
  let!(:family_2) { create :family, name: 'Barkins', users: [user] }
  let(:id) { family.id }

  path '/api/v1/families/quick_list' do
    before do
      family.kinship_for(user).update!(nickname: 'some nick')
    end

    get('quick_list family') do
      include_context 'cookie'
      tags 'Family'
      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data'].size).to eq 3
          expect(response.parsed_body['data'][0]['attributes']['name']).to eq family_2.name
          expect(response.parsed_body['data'][1]['attributes']['name']).to eq family_1.name
          expect(response.parsed_body['data'][2]['attributes']['name']).to eq 'Z-last'
          expect(response.body).to include('some nick')
          expect(response.body).to include(family.id)
        end
      end
    end
  end

  path '/api/v1/families' do
    get('list families') do
      include_context 'cookie'
      tags 'Family'
      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data'].size).to eq 3
          expect(response.parsed_body['data'][0]['attributes']['name']).to eq 'Barkins'
          expect(response.parsed_body['data'][1]['attributes']['name']).to eq 'Purrkins'
          expect(response.parsed_body['data'][2]['attributes']['name']).to eq 'Z-last'
        end
      end
    end

    post('create family') do
      include_context 'cookie'
      tags 'Family'
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          motto: { type: :string },
          cover: { type: :string },
          family_type: { type: :string }
        }
      }
      let(:payload) do
        {
          name: name,
          motto: 'some test description',
          cover: image_blob.signed_id,
          family_type: 'some'
        }
      end
      let(:image_blob) { create_file_blob }
      let(:name) { 'some name' }

      response(200, 'successful', save_request_example: :payload) do
        before do
          expect(user.families.count).to eq(3)
        end

        run_test! do
          expect(user.families.count).to eq(4)
          expect(response.parsed_body['data']['attributes']['name']).to eq(name)
          expect(response.parsed_body['data']['attributes']['family_type']).to eq('some')
        end
      end
    end
  end

  path '/api/v1/families/{id}' do
    parameter name: 'id', in: :path, type: :string

    get('show family') do
      include_context 'cookie'
      tags 'Family'
      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data']['attributes']['name']).to eq(family.name)
        end
      end
    end

    patch('update family') do
      include_context 'cookie'
      tags 'Family'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          motto: { type: :string },
          cover: { type: :string },
          description: { type: :string }
        }
      }
      let(:payload) do
        {
          name: name,
          motto: 'some test description',
          description: 'some body',
          cover: image_blob.signed_id
        }
      end
      let(:name) { 'some name' }
      let(:image_blob) { create_file_blob }

      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(family.reload).to have_attributes(
            name: name,
            motto: 'some test description',
            description: 'some body'
          )
          expect(response.parsed_body['data']['attributes']['name']).to eq(name)
        end
      end
    end

    delete('delete family') do
      include_context 'cookie'
      tags 'Family'

      response(204, 'successful') do
        before do
          stub_mandrill
          # allow to destroy family with members
          create :kinship, family: family, user: create(:user)
          expect(Family.default_access.count).to eq(3)
        end

        run_test! do
          expect(Family.default_access.count).to eq(2)
          expect(all_emails.map(&:subject)).to contain_exactly("#{family.name} Deleted")
        end
      end
    end
  end
end
