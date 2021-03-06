require 'swagger_helper'

RSpec.describe Api::V1::Vaults::AttachmentsController, type: :request do
  let(:user) { create :user }
  let(:vault_id) { user.vault.id }
  let(:image_blob) { create_file_blob }
  let(:image_blob_2) { create_file_blob }
  let(:subscription) do
    create :subscription,
           user: user,
           current_period_start: Time.current - 1.day,
           current_period_end: Time.current + 1.day
  end

  path '/api/v1/vaults/{vault_id}/attachments' do
    parameter name: 'vault_id', in: :path, type: :string

    post('create attachment') do
      include_context 'cookie'
      tags 'Attachment'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          box_id: { type: :string },
          files: {
            type: :array,
            items: {
              type: :object,
              properties: {
                title: { type: :string },
                signed_id: { type: :string }
              }
            }
          }
        }
      }
      let(:payload) do
        {
          box_id: nil,
          files: [
            { signed_id: image_blob.signed_id, title: 'some title 1' },
            { signed_id: image_blob_2.signed_id }
          ]
        }
      end
      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(response.parsed_body['data'].size).to eq(2)
          image1 = response.parsed_body['data'].find { |x| x['attributes']['blob_signed_id'] == image_blob.signed_id }
          image2 = response.parsed_body['data'].find { |x| x['attributes']['blob_signed_id'] == image_blob_2.signed_id }
          expect(image1['attributes']['cover_url']).to be_present
          expect(image1['attributes']['blob_signed_id']).to be_present
          expect(image1['attributes']['name']).to eq('some title 1.jpg')
          expect(image2['attributes']['cover_url']).to be_present
          expect(image2['attributes']['blob_signed_id']).to be_present
          expect(image2['attributes']['name']).to eq('image.jpg')
        end
      end
    end
  end

  path '/api/v1/vaults/{vault_id}/attachments/move' do
    parameter name: 'vault_id', in: :path, type: :string

    post('move attachment') do
      include_context 'cookie'
      tags 'Attachment'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          box_id: { type: :string },
          ids: { type: :array }
        },
        required: %w[update_me_param]
      }
      let(:box) { create :box, vault: user.vault }
      let(:attachment) { create :active_storage_attachment, record: user.vault, blob: image_blob, user: user }
      let(:payload) do
        {
          box_id: box.id,
          ids: [attachment.id]
        }
      end
      response(204, 'successful', save_request_example: :payload) do
        before do
          expect(attachment.box_id).to eq(nil)
        end

        run_test! do
          expect(attachment.reload.box_id).to eq(box.id)
        end
      end
    end
  end

  path '/api/v1/vaults/{vault_id}/attachments/copy' do
    parameter name: 'vault_id', in: :path, type: :string

    post('copy attachment') do
      include_context 'cookie'
      tags 'Attachment'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          ids: { type: :array },
          new_vault_id: { type: :string },
          box_id: { type: :string }
        },
        required: %w[ids new_vault_id]
      }
      let(:family) { create :family, users: [user] }
      let(:family_vault) { family.vault }
      let(:box) { create :box, vault: family_vault }
      let(:attachment) { create :active_storage_attachment, record: user.vault, blob: image_blob, user: user }
      let(:payload) do
        {
          ids: [attachment.id],
          new_vault_id: family_vault.id,
          box_id: box.id
        }
      end

      response(204, 'successful', save_request_example: :payload) do
        before do
          expect(family_vault.files.size).to eq(0)
          expect(box.attachments.size).to eq(0)
        end

        run_test! do
          expect(family_vault.reload.files.size).to eq(1)
          expect(box.reload.attachments.size).to eq(1)
        end
      end
    end
  end

  path '/api/v1/vaults/{vault_id}/attachments/{id}' do
    parameter name: 'vault_id', in: :path, type: :string
    parameter name: 'id', in: :path, type: :string
    let!(:attachment) { create :active_storage_attachment, record: user.vault, blob: image_blob, user: user }
    let(:id) { attachment.id }

    patch('update attachment') do
      include_context 'cookie'
      tags 'Attachment'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string }
        },
        required: %w[title]
      }
      let(:payload) do
        {
          title: 'new title'
        }
      end
      response(200, 'successful', save_request_example: :payload) do
        run_test! do
          expect(response.parsed_body['data']['attributes']['name']).to eq('new title.jpg')
        end
      end
    end
  end
end
