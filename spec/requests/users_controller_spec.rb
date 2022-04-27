require 'swagger_helper'
RSpec.describe UsersController, type: :request do
  path '/users' do
    post('create user') do
      tags 'User'
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          invitation_id: { type: :string },
          user: {
            type: :object,
            properties: {
              first_name: { type: :string },
              last_name: { type: :string },
              email: { type: :string },
              password: { type: :string },
              terms_and_conditions: { type: :boolean }
            }
          }
        }
      }
      let(:payload) do
        {
          user: {
            first_name: 'first',
            last_name: 'last',
            email: email,
            password: 'secret',
            terms_and_conditions: true
          }
        }
      end
      let(:email) { 'some@email.com' }
      let(:invitation_id) { nil }

      before do
        stub_mandrill
        cookies[:invitation_id] = invitation_id
      end

      response(302, 'successful', save_request_example: :payload) do
        before do
          expect(User.count).to eq(0)
        end

        run_test! do
          expect(User.count).to eq(1)
          expect(all_emails.size).to eq(1)
          user = User.find_by(email: email)
          expect(user).to have_attributes(
            first_name: 'first',
            last_name: 'last',
            email: email,
            registration_method: 'direct'
          )
        end
      end

      response(302, 'stg invalid mail', document: false) do
        before do
          allow(Rails.env).to receive(:staging?).and_return(true)
          expect(User.count).to eq(0)
        end

        run_test! do
          expect(User.count).to eq(0)
        end
      end

      response(302, 'stg valid mail', document: false) do
        let(:email) { 'some+kintest@email.com' }
        before do
          allow(Rails.env).to receive(:staging?).and_return(true)
          expect(User.count).to eq(0)
        end

        run_test! do
          expect(User.count).to eq(1)
          expect(all_emails.size).to eq(1)
        end
      end

      context 'with invitation' do
        let(:sender) { create :user }
        let(:family) { create :family, users: [sender] }
        let!(:invitation) { create :invitation, family: family, sender: sender, email: email, kinship: kinship }
        let(:kinship) { nil }
        let(:invitation_id) { invitation.id }

        response(302, 'community', document: false) do
          before do
            expect(User.count).to eq(1)
          end

          run_test! do
            expect(User.count).to eq(2)
            expect(all_emails.map(&:subject)).to contain_exactly(
              'Confirm your Email', 'New Community Member'
            )
            expect(invitation.reload.recipient).to eq(User.find_by(email: email))
            expect(User.find_by(email: email).registration_method).to eq('member')
          end
        end

        response(302, 'followers', document: false) do
          let(:family) { sender.personal_family }

          before do
            expect(User.count).to eq(1)
          end

          run_test! do
            expect(User.count).to eq(2)
            expect(all_emails.map(&:subject)).to contain_exactly('Confirm your Email')
            expect(User.find_by(email: email).registration_method).to eq('follower')
          end
        end

        response(302, 'offline', document: false) do
          let(:kinship) { create :offline_member, family: family }

          before do
            expect(User.count).to eq(1)
          end

          run_test! do
            expect(User.count).to eq(2)
            expect(all_emails.map(&:subject)).to contain_exactly(
              'Confirm your Email', 'New Community Member'
            )
            expect(User.find_by(email: email).registration_method).to eq('offline')
          end
        end
      end

      context 'with existing user' do
        let!(:existing_user) { create :user, email: email, confirmed_at: confirmed_at, updated_at: updated_at }
        let(:updated_at) { Time.current }
        let(:confirmed_at) { nil }

        response(200, 'do nothing', document: false) do
          before do
            expect(User.count).to eq(1)
          end

          run_test! do
            expect(User.count).to eq(1)
            expect(all_emails.size).to eq(0)
          end
        end

        response(200, 'confirmed - do nothing', document: false) do
          let(:confirmed_at) { Time.zone.now - 1.day }
          before do
            expect(User.count).to eq(1)
          end

          run_test! do
            expect(User.count).to eq(1)
            expect(all_emails.size).to eq(0)
          end
        end

        response(302, 'unconfirmed and updated more than 1 hour ago - resend mail', document: false) do
          let(:updated_at) { Time.current - 61.minutes }
          before do
            expect(User.count).to eq(1)
          end

          run_test! do
            expect(User.count).to eq(1)
            expect(all_emails.size).to eq(1)
          end
        end
        context 'with invitation' do
          let(:sender) { create :user }
          let(:family) { create :family, users: [sender] }
          let!(:invitation) { create :invitation, family: family, sender: sender, email: email }
          let(:invitation_id) { invitation.id }

          response(302, 'unconfirmed and updated more than 1 hour ago - resend mail', document: false) do
            let(:updated_at) { Time.current - 61.minutes }
            before do
              expect(User.count).to eq(2)
              expect(invitation.recipient).to eq(nil)
            end

            run_test! do
              expect(User.count).to eq(2)
              expect(all_emails.size).to eq(1)
              expect(invitation.reload.recipient).to eq(existing_user)
            end
          end
        end
      end

      response(200, 'recaptcha', document: false) do
        before do
          Recaptcha.configuration.skip_verify_env.delete('test')
          expect(User.count).to eq(0)
        end

        after do
          Recaptcha.configuration.skip_verify_env << 'test'
        end

        run_test! do
          expect(User.count).to eq(0)
        end
      end
    end
  end
end
