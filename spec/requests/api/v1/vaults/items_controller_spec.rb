require 'swagger_helper'

RSpec.describe Api::V1::Vaults::ItemsController, type: :request do
  let(:user) { create :user }
  let(:vault) { user.vault }
  let(:vault_id) { vault.id }
  let(:image_blob1) { create_file_blob(filename: 'image.jpg') }
  let(:image_blob2) { create_file_blob(filename: 'image_2.png') }
  let(:image_blob3) { create_file_blob(filename: 'image_3.png') }
  let!(:attachment1) { create :active_storage_attachment, record: vault, blob: image_blob1, user: user }
  let!(:attachment2) { create :active_storage_attachment, record: vault, blob: image_blob2, user: user }
  let!(:attachment3) { create :active_storage_attachment, record: vault, blob: image_blob3, user: user, box: box1 }

  let(:parent_box) { create :box, vault: vault }

  let!(:box1) { create :box, vault: vault, parent_box: parent_box }
  let!(:box2) { create :box, vault: vault, parent_box: parent_box }

  let(:subscription) do
    create :subscription,
           user: user,
           current_period_start: Time.current - 1.day,
           current_period_end: Time.current + 1.day
  end

  path '/api/v1/vaults/{vault_id}/items' do
    parameter name: 'vault_id', in: :path, type: :string

    delete('bulk_delete files and boxes') do
      include_context 'cookie'
      tags 'Vault'

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

      response(204, 'successful', save_request_example: :payload) do
        before do
          subscription
          expect(ActiveStorage::Attachment.count).to eq(3)
          expect(Box.count).to eq(3)
        end

        run_test! do
          expect(ActiveStorage::Attachment.count).to eq(0)
          expect(Box.count).to eq(1)
          parent_box.reload
          expect { attachment3.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'with child box' do
        before { create :box, vault: vault, parent_box: box1 }

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
        let(:vault) { create :vault, owner: family }
        let(:attachment2) { create :active_storage_attachment, record: vault, blob: image_blob2, user: another_user }

        response(401, 'with selected file of another user it return error', save_request_example: :payload) do
          run_test!
        end
      end
    end
  end
end
