require 'swagger_helper'

RSpec.describe Api::V1::Kinships::OfflineMembersController, type: :request do
  let(:user) { create :user }
  let(:other_user) { create :user }
  let!(:family) { create :family, users: [user, other_user] }
  let(:kinship) { other_user.kinships.find_by(family: family) }
  let(:kinship_id) { kinship.id }

  path '/api/v1/kinships/{kinship_id}/offline_member' do
    parameter name: 'kinship_id', in: :path, type: :string

    patch('migrate active user to offline member') do
      include_context 'cookie'
      tags 'Offline Member'

      response(200, 'successful') do
        before do
          expect(kinship.role).to eq('member')
          stub_mandrill
        end

        run_test! do
          expect(kinship.reload.role).to eq('offline_member')
          expect(kinship.user_id).to eq(nil)
          expect(all_emails.map(&:to).flatten).to contain_exactly(other_user.email)
        end
      end

      context 'with admin' do
        let(:kinship_id) { family.admin_kinship.id }

        response(422, 'error') do
          run_test! do
            expect(response.parsed_body['errors']['detail']).to eq(
              'You are the admin for this community, please pass admin rights over to another user.'
            )
          end
        end
      end
    end
  end
end
