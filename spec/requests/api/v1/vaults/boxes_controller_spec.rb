require 'swagger_helper'

RSpec.describe Api::V1::Vaults::BoxesController, type: :request do
  let(:user) { create :user }
  let(:vault) { user.vault }
  let(:vault_id) { vault.id }

  path '/api/v1/vaults/{vault_id}/boxes' do
    parameter name: 'vault_id', in: :path, type: :string

    post('create box') do
      include_context 'cookie'
      tags 'Box'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          parent_box_id: { type: :string }
        },
        required: %w[name]
      }
      let(:parent_box) { create :box, vault: vault }
      let(:payload) do
        {
          name: 'box name',
          parent_box_id: parent_box.id
        }
      end
      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(response.parsed_body['data']['attributes']['name']).to eq('box name')
        end
      end
    end
  end

  path '/api/v1/vaults/{vault_id}/boxes/{id}' do
    parameter name: 'vault_id', in: :path, type: :string
    parameter name: 'id', in: :path, type: :string

    let!(:parent_parent_box) { create :box, vault: vault, name: 'parent_parent' }
    let!(:parent_box) { create :box, vault: vault, parent_box: parent_parent_box, name: 'parent' }
    let(:box) { create :box, vault: vault, parent_box: parent_box, name: 'child' }
    let(:image_blob) { create_file_blob }
    let(:id) { box.id }

    get('show box') do
      include_context 'cookie'
      tags 'Box'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data']['attributes']['name']).to eq(box.name)
          expect(response.parsed_body['data']['attributes']['parent_boxes'].first['id']).to eq(parent_parent_box.id)
          expect(response.parsed_body['data']['attributes']['parent_boxes'].second['id']).to eq(parent_box.id)
          expect(response.parsed_body['data']['attributes']['parent_boxes'].size).to eq(2)
        end
      end
    end

    patch('update box') do
      include_context 'cookie'
      tags 'Box'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          parent_box_id: { type: :string }
        }
      }

      let(:parent_box) { create :box, vault: vault }
      let(:box) { create :box, vault: vault, parent_box: parent_box }
      let(:id) { box.id }

      let(:payload) do
        {
          parent_box_id: nil
        }
      end
      response(200, 'change parent box', save_request_example: :payload) do
        run_test! do
          expect(box.reload.parent_box_id).to be_nil
        end
      end

      context 'without parent_box_id' do
        let(:payload) do
          {
            name: 'box name'
          }
        end

        response(200, 'change name', save_request_example: :payload) do
          run_test! do
            expect(response.parsed_body['data']['attributes']['name']).to eq('box name')
            expect(box.reload.parent_box).to eq(parent_box)
          end
        end
      end
    end
  end
end
