module Billing
  class CardsController < ApplicationController
    before_action :set_plans

    def create
      updated_result = Billing::SubscriptionService.update_stripe_subscription(
        current_user, params[:stripe_token], params[:plan_id]
      )

      if updated_result == true
        flash[:success] = t('billing.payment_method.flashes.success')
        redirect_to account_path
      else
        flash[:error] = updated_result ||
                        t('billing.payment_method.flashes.error')
        render action: :new
      end
    end

    private

    def set_plans
      @plans = []

      individual_plan = StripePlan.find_by(
        plan_id: ENV['STRIPE_INDIVIDUAL_PLAN_ID']
      )
      group_plan = StripePlan.find_by(
        plan_id: ENV['STRIPE_GROUP_PLAN_ID']
      )

      @plans << individual_plan if individual_plan
      @plans << group_plan if group_plan

      @current_plan_id = current_user.subscription&.plan_id
      @current_card = current_user.default_payment_method
    end
  end
end
