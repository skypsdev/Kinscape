require 'swagger_helper'
# rubocop:disable RSpec/VariableName
RSpec.describe Vaults::DownloadsController, type: :request do
  let(:user) { create :user }
  let(:vault_id) { user.vault.id }
  let(:image_blob1) { create_file_blob(filename: 'image.jpg') }
  let(:image_blob2) { create_file_blob(filename: 'image_2.png') }
  let(:attachment1) { create :active_storage_attachment, record: user.vault, blob: image_blob1, title: 'some' }
  let(:attachment2) { create :active_storage_attachment, record: user.vault, blob: image_blob2 }

  path '/vaults/{vault_id}/download' do
    get('download') do
      include_context 'cookie'
      tags 'Download'

      parameter name: :vault_id, in: :path, type: :string
      parameter name: :'ids[]', collectionFormat: :multi, in: :query, type: :array

      let(:'ids[]') { [attachment1.id] }

      response(302, 'successful - one file') do
        run_test!
      end

      response(200, 'successful - multiple files') do
        let(:'ids[]') { [attachment1.id.to_s, attachment2.id.to_s] }
        run_test! do
          expect(response.headers['Content-Disposition']).to include 'attachment'
        end
      end
    end
  end
end
# rubocop:enable RSpec/VariableName
