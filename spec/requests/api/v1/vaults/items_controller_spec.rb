require 'swagger_helper'

RSpec.describe Api::V1::Vaults::ItemsController, type: :request do
  let(:user) { create :user }
  let(:vault_id) { user.vault.id }

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

  let(:subscription) do
    create :subscription,
           user: user,
           current_period_start: Time.current - 1.day,
           current_period_end: Time.current + 1.day
  end

  path '/api/v1/vaults/{vault_id}/items' do
    parameter name: 'vault_id', in: :path, type: :string

    get('list files and boxes') do
      include_context 'cookie'
      tags 'VaultItems'

      parameter name: :query, in: :query, type: :string
      parameter name: :box_id, in: :query, type: :string
      parameter name: :sort_direction, in: :query, type: :string, enum: %w[ASC DESC], default: 'DESC'
      parameter name: :sort_by, in: :query, type: :string, enum: %w[name content_type created_at], default: 'created_at'
      parameter name: :per_page, in: :query, type: :integer, default: 10
      parameter name: :only_boxes, in: :query, type: :boolean, default: false
      parameter name: :showcase_family, in: :query, type: :boolean
      parameter name: :showcase, in: :query, type: :boolean

      let(:showcase) { nil }
      let(:showcase_family) { nil }
      let(:box_id) { nil }
      let(:query) { nil }
      let(:per_page) { nil }
      let(:sort_by) { 'name' }
      let(:sort_direction) { nil }
      let(:only_boxes) { nil }

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
          expect(response_image['attributes']['name']).to eq("#{attachment2.title}.png")
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

    delete('bulk_delete files and boxes') do
      include_context 'cookie'
      tags 'VaultItems'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          boxes_ids: { type: :array },
          files_ids: { type: :array }
        }
      }
      let(:payload) do
        {
          boxes_ids: [box1.id, box2.id],
          files_ids: [attachment1.id, attachment2.id]
        }
      end

      let!(:attachment3) do
        create :active_storage_attachment, record: user.vault, blob: image_blob3, user: user, box: box2
      end

      response(204, 'successful', save_request_example: :payload) do
        before do
          subscription
          expect(ActiveStorage::Attachment.count).to eq(4)
          expect(Box.count).to eq(3)
        end

        run_test! do
          expect(ActiveStorage::Attachment.count).to eq(0)
          expect(Box.count).to eq(1)
          expect { attachment3.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'with child box' do
        before { create :box, vault: user.vault, parent_box: box1 }

        response(403, 'with child box it return error', save_request_example: :payload) do
          run_test! do
            expect(response.parsed_body['message']).to eq(
              'Some of the selected boxes contain child boxes, please deselect them first.'
            )
          end
        end
      end

      context 'with other user files' do
        let(:another_user) { create :user }
        let!(:family) { create :family, users: [user, another_user] }
        let(:attachment2) do
          create :active_storage_attachment, record: family.vault, blob: image_blob2, user: another_user
        end

        response(401, 'with selected file of another user it return error', save_request_example: :payload) do
          run_test!
        end
      end
    end
  end
end
