require 'swagger_helper'

RSpec.describe Api::V1::CategoriesController, type: :request do
  let(:user) { create :user }
  let(:family) { create :family, users: [user] }
  let(:categories) { %w[12 moon sun] }
  let(:story) { create :story, user: user, category_list: categories }

  before { create :publication, story: story, family: family }

  path '/api/v1/categories' do
    get('list categories') do
      include_context 'cookie'
      tags 'Category'

      response(200, 'successful') do
        run_test! do
          expect(response.parsed_body['data']).to contain_exactly(
            { 'number' => 1, 'text' => 'sun' }, { 'number' => 1, 'text' => 'moon' }, { 'number' => 1, 'text' => '12' }
          )
        end
      end
    end
  end
end
