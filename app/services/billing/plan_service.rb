module Billing
  class PlanServiceError < StandardError; end

  class PlanService
    class << self
      def stripe_create(attributes)
        Stripe::Plan.create(
          id: attributes[:id],
          nickname: attributes[:nickname],
          currency: attributes[:currency],
          amount: attributes[:amount],
          interval: attributes[:interval],
          trial_period_days: attributes[:trial_period_days],
          product: ENV['STRIPE_PRODUCT_ID']
        )
      end

      def delete(stripe_id)
        StripePlan.find_by!(plan_id: stripe_id).destroy!
      end

      def stripe_delete(stripe_id)
        Stripe::Plan.delete(stripe_id)
      end

      def update(attributes)
        plan = StripePlan.find_or_create_by!(plan_id: attributes.id)

        plan.update!(
          nickname: attributes.nickname,
          currency: attributes.currency,
          amount: attributes.amount,
          interval: attributes.interval,
          trial_period_days: attributes.trial_period_days,
          product: attributes.product
        )

        plan
      end

      def stripe_update(attributes)
        Stripe::Plan.update(
          attributes[:id],
          nickname: attributes[:nickname],
          trial_period_days: attributes[:trial_period_days]
        )
      end
    end
  end
end
