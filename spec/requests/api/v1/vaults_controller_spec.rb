require 'swagger_helper'

RSpec.describe Api::V1::VaultsController, type: :request do
  let(:user) { create :user }
  let(:user_vault) { user.vault }
  let(:id) { user_vault.id }

  path '/api/v1/vaults/{id}' do
    parameter name: :id, in: :path, type: :string
    parameter name: :query, in: :query, type: :string
    parameter name: :box_id, in: :query, type: :string
    parameter name: :sort_direction, in: :query, type: :string, enum: %w[ASC DESC], default: 'DESC'
    parameter name: :sort_by, in: :query, type: :string, enum: %w[name content_type created_at], default: 'created_at'
    parameter name: :per_page, in: :query, type: :integer, default: 10
    parameter name: :only_boxes, in: :query, type: :boolean, default: false

    let(:box_id) { nil }
    let(:query) { nil }
    let(:per_page) { nil }
    let(:sort_by) { 'name' }
    let(:sort_direction) { nil }
    let(:only_boxes) { nil }

    let(:image_blob1) { create_file_blob(filename: 'image.jpg') }
    let(:image_blob2) { create_file_blob(filename: 'image_2.png') }
    let(:image_blob3) { create_file_blob(filename: 'image_3.png') }
    let(:image_blob4) { create_file_blob(filename: 'image_4.png') }
    let!(:attachment1) { create :active_storage_attachment, record: user.vault, blob: image_blob1, user: user }
    let!(:attachment2) do
      create :active_storage_attachment, record: user.vault, blob: image_blob2, user: user, title: 'summer'
    end
    let!(:attachment3) { create :active_storage_attachment, record: user.vault, blob: image_blob3, user: user }
    let!(:box1) { create :box, vault: user.vault, name: 'a1' }
    let!(:box2) { create :box, vault: user.vault, name: 'z2' }
    let!(:box3) { create :box, vault: user.vault, name: 'g3' }
    let!(:box_attachment) do
      create :active_storage_attachment, record: user.vault, blob: image_blob4, box: box1, user: user
    end

    get('show vault') do
      include_context 'cookie'
      tags 'Vault'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data'].size).to eq(6)
          expect(response.parsed_body['data'].pluck('id')).to match_array(
            [box1.id.to_s, box3.id.to_s, box2.id.to_s, attachment1.id.to_s, attachment3.id.to_s, attachment2.id.to_s]
          )
          nested_attachment = response.parsed_body['data'].find do |x|
            x['attributes']['item_type'] == 'file' && x['id'] == box_attachment.id.to_s
          end
          expect(nested_attachment).to eq(nil)
          response_box = response.parsed_body['data'].find do |x|
            x['attributes']['item_type'] == 'box' && x['id'] == box1.id.to_s
          end
          expect(response_box['attributes']['name']).to eq(box1.name)
          expect(response_box['attributes']['cover_url']).to eq(nil)
          response_image = response.parsed_body['data'].find do |x|
            x['attributes']['item_type'] == 'file' && x['id'] == attachment2.id.to_s
          end
          expect(response_image['attributes']['name']).to eq(attachment2.title)
          expect(response_image['attributes']['cover_url']).to be_present
        end
      end

      response(200, 'only boxes', document: false) do
        let(:only_boxes) { true }
        run_test! do
          expect(response.parsed_body['data'].size).to eq(3)
          expect(response.parsed_body['data'].pluck('id')).to match_array(
            [box1.id.to_s, box3.id.to_s, box2.id.to_s]
          )
        end
      end
    end
  end

  path '/api/v1/vaults' do
    parameter name: :query, in: :query, type: :string

    let(:query) { nil }

    let(:family_1) { create :family, users: [user], name: 'Summer 2008' }
    let(:family_2) { create :family, users: [user], name: 'Summer 2004' }
    let(:family_3) { create :family, users: [user], name: 'Summer 2007' }
    let(:family_4) { create :family, users: [user], name: 'Aloha 2000' }
    let!(:vault_1) { create :vault, owner: family_1 }
    let!(:vault_2) { create :vault, owner: family_2 }
    let!(:vault_3) { create :vault, owner: family_3 }
    let!(:vault_4) { create :vault, owner: family_4 }

    get('list vaults') do
      include_context 'cookie'
      tags 'Vault'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data'].pluck('id')).to eq(
            [user_vault.id.to_s, vault_4.id.to_s, vault_2.id.to_s, vault_3.id.to_s, vault_1.id.to_s]
          )
        end
      end

      response(200, 'successful', document: false) do
        let(:query) { 'summer' }

        run_test! do
          expect(response.parsed_body['data'].pluck('id')).to eq(
            [vault_2.id.to_s, vault_3.id.to_s, vault_1.id.to_s]
          )
        end
      end
    end
  end
end
