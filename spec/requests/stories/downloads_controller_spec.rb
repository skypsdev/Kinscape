require 'swagger_helper'

RSpec.describe Stories::DownloadsController, type: :request do
  let(:user) { create :user }
  let(:story) { create :story, user: user }
  let(:image_blob) { create_file_blob }
  let(:rich_body) { ActionText::Content.new('some text').append_attachables(image_blob) }

  before { create :section, author: user, story: story, rich_body: rich_body }

  path '/stories/{story_id}/download' do
    parameter name: :story_id, in: :path, type: :string

    let(:story_id) { story.uid }

    get('download') do
      include_context 'cookie'
      tags 'Download'

      response(200, 'successful') do
        run_test! do
          expect(response.headers['Content-Disposition']).to include 'attachment'
        end
      end
    end
  end
end
