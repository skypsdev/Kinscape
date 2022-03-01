require 'spec_helper'

describe Api::V1::RequestsController, type: :controller do
  describe '#create' do
    it 'sends an email to recipient' do
      requester = create(:user)
      recipient = create(:user)
      family = create(:family, users: [requester, recipient])
      sign_in_as requester
      request.env['HTTP_REFERER'] = user_path(recipient)
      stub_mandrill

      post :create,
           params: {
             request: {
               family_id: family.uid,
               kinships_ids: [recipient.kinships.first.id],
               message: 'Blah'
             }
           }

      delivery = ActionMailer::Base.deliveries.last
      expect(ActionMailer::Base.deliveries.size).to eq(2)
      expect(response.status).to eq 204

      expect(delivery.to_addrs).to include(requester.email)
    end

    it 'sends an email to multiple recipients' do
      requester = create(:user)
      recipient = create(:user)
      recipient_2 = create(:user)
      family = create(:family, users: [requester, recipient, recipient_2])

      sign_in_as requester
      request.env['HTTP_REFERER'] = user_path(recipient)
      stub_mandrill

      post :create,
           params: {
             request: {
               family_id: family.uid,
               kinships_ids: [recipient.kinships.first.id, recipient_2.kinships.first.id],
               message: 'Blah'
             }
           }

      delivery = ActionMailer::Base.deliveries.first

      expect(ActionMailer::Base.deliveries.size).to eq(2)
      expect(response.status).to eq 204

      expect(delivery.to_addrs).to include(recipient.email)
      expect(delivery.to_addrs).to include(recipient_2.email)

      # expect(delivery.cc_addrs).to include(requester.email)

      expect(delivery.reply_to).to include(requester.email)
    end
  end
end
