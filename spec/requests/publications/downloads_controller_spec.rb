require 'swagger_helper'

RSpec.describe Publications::DownloadsController, type: :request do
  let(:user) { create :user }
  let(:story) { create :story, user: user }
  let(:publication) { create :publication, story: story, family: user.personal_family }
  let(:image_blob) { create_file_blob }
  let(:rich_body) { ActionText::Content.new('some text').append_attachables(image_blob) }

  before do
    create :family, users: [user]
    create :section, author: user, story: story, rich_body: rich_body
  end

  path '/publications/{publication_id}/download' do
    parameter name: :publication_id, in: :path, type: :string

    let(:publication_id) { publication.id }

    get('download') do
      include_context 'cookie'
      tags 'Download'

      response(200, 'successful') do
        if ENV['SKIP_ON_CI'].nil?
          run_test! do
            expect(response.headers['Content-Disposition']).to include 'attachment'
          end
        end
      end
    end
  end
end
