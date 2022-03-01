require 'spec_helper'

feature 'Billing card', :js do
  let(:user) { create :user }
  let(:subscription) { create(:subscription, user: user) }

  context 'when the individual and group plans exist' do
    let(:individual_plan) { create(:stripe_plan, plan_id: 'basic') }
    let(:group_plan) { create(:stripe_plan, plan_id: 'group') }

    background do
      ENV['STRIPE_INDIVIDUAL_PLAN_ID'] = individual_plan.plan_id
      ENV['STRIPE_GROUP_PLAN_ID'] = group_plan.plan_id
    end

    # Temp. remove payment feature
    # scenario 'shows the both plans' do
    #   visit new_billing_card_path as: user

    #   expect(page).to have_text "#{individual_plan.nickname} Plan"
    #   expect(page).to have_text "#{group_plan.nickname} Plan"
    # end

    context 'when the user is subscribed to a plan' do
      background do
        subscription.update(
          billing_plan_data: { id: individual_plan.plan_id }
        )
      end

      # Temp. remove payment feature
      # scenario 'the plan is preselected' do
      #   visit new_billing_card_path as: user

      #   expect(find('.card.selected')['data-plan-id']).to \
      #     eq individual_plan.plan_id
      # end

      xscenario 'can switch the plan' do
        visit new_billing_card_path as: user
        dismiss_cookieconsent

        find(".card[data-plan-id='group']").click

        expect(Billing::SubscriptionService).to \
          receive(:update_stripe_subscription).with(
            user, nil, 'group'
          ).and_return(true)

        find('.payment-method__submit').click_on 'Continue'
      end
    end
  end
end
