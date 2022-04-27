module Billing
  class SubscriptionServiceError < StandardError; end

  # rubocop:disable Metrics/ClassLength
  # rubocop:disable Metrics/BlockLength
  class SubscriptionService
    class << self
      def cancel_for(user)
        return unless user.stripe_id || user.subscription&.stripe_id

        stripe_subscription = \
          Stripe::Subscription.retrieve(user.subscription.stripe_id)

        stripe_subscription.cancel_at_period_end = true
        stripe_subscription.save

        user.subscription.update(cancel_at_period_end: true)
      end

      def renew_for(user)
        return unless user.stripe_id

        customer = find_or_create_stripe_customer_for(user)

        if customer.sources.total_count.zero?
          raise Billing::SubscriptionServiceError,
                I18n.t('subscriptions.errors.no_payment_method')
        end

        if subscriptions?(customer)
          stripe_subscription = \
            Stripe::Subscription.retrieve(customer.subscriptions.data[0].id)

          stripe_subscription.delete
          user.subscription&.delete
        end

        stripe_subscription = subscribe_customer_to(
          customer,
          current_plan.id,
          trial_end: 'now'
        )

        ActiveRecord::Base.transaction do
          subscription = Subscription.new(
            stripe_id: stripe_subscription.id,
            user_id: user.id,
            trial_end: DateTime.now,
            trial_start: DateTime.now,
            current_period_end: Time.zone.at(
              stripe_subscription.current_period_end
            ).to_datetime,
            current_period_start: Time.zone.at(
              stripe_subscription.current_period_start
            ).to_datetime,
            cancel_at_period_end: stripe_subscription.cancel_at_period_end,
            status: stripe_subscription.status,
            billing_plan_data: stripe_subscription.plan
          )

          subscription.save!

          user.subscription = subscription
          user.save!

          subscription
        end
      end

      def resume_for(user)
        return unless user.stripe_id || user.subscription&.stripe_id

        stripe_subscription = \
          Stripe::Subscription.retrieve(user.subscription.stripe_id)

        item_id = stripe_subscription.items.data[0].id
        items = [{
          id: item_id,
          plan: current_plan.id
        }]
        stripe_subscription.items = items
        stripe_subscription.save

        user.subscription.update(cancel_at_period_end: false)
      end

      def delete(stripe_id)
        Subscription.find_by!(stripe_id: stripe_id).destroy!
      end

      def update(attributes)
        subscription = Subscription.find_by!(stripe_id: attributes.id)

        subscription.update!(
          trial_end: attributes.trial_end &&
            Time.zone.at(attributes.trial_end).to_datetime,
          trial_start: attributes.trial_start &&
            Time.zone.at(attributes.trial_start).to_datetime,
          current_period_end: attributes.current_period_end && Time.zone.at(
            attributes.current_period_end
          ).to_datetime,
          current_period_start: attributes.current_period_start && Time.zone.at(
            attributes.current_period_start
          ).to_datetime,
          cancel_at_period_end: attributes.cancel_at_period_end,
          status: attributes.status,
          billing_plan_data: attributes.plan
        )
      end

      # TODO-RUBOCOP
      # rubocop:disable Metrics/CyclomaticComplexity
      def update_stripe_subscription(user, stripe_token, plan_id)
        return false if stripe_token.nil? && plan_id.nil?

        stripe_customer = \
          Billing::SubscriptionService.find_or_create_stripe_customer_for(
            user
          )

        stripe_subscription = Stripe::Subscription.retrieve(
          user.subscription.stripe_id
        )

        ActiveRecord::Base.transaction do
          subscription = Subscription.find_by!(
            stripe_id: user.subscription.stripe_id
          )

          if stripe_token
            stripe_customer.source = stripe_token

            begin
              return false unless stripe_customer.save
            rescue Stripe::CardError => e
              return e.error.message
            end

            unless subscription.active?
              stripe_subscription.trial_end = 'now'

              subscription.trial_end = Time.zone.now
              subscription.current_period_end = Time.zone.now
              subscription.status = 'active'
            end
          end

          unless plan_id == stripe_subscription.plan&.id
            stripe_subscription.items = [
              {
                id: stripe_subscription.items.data[0].id,
                plan: plan_id
              }
            ]

            if stripe_subscription.status == 'active'
              stripe_subscription.billing_cycle_anchor = 'now'
            end
          end

          stripe_subscription.save

          subscription.billing_plan_data = stripe_subscription.plan

          subscription.save
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def find_or_create_stripe_customer_for(user)
        return find_stripe_customer(user.stripe_id) if user.stripe_id

        create_stripe_customer_from(user)
      end

      def find_stripe_customer(stripe_id)
        Stripe::Customer.retrieve stripe_id
      end

      def create_stripe_customer_from(user)
        customer = Stripe::Customer.create(
          email: user.email,
          metadata: {
            first_name: user.first_name,
            last_name: user.last_name
          }
        )

        return false unless customer

        if assign_stripe_id_to(user, customer.id)
          customer
        else
          Stripe::Customer.delete(customer.id)
          nil
        end
      end

      def assign_stripe_id_to(assignee, id)
        assignee.update_attribute :stripe_id, id
      end

      def subscribe(user, plan = current_plan)
        return false if user.subscription

        begin
          customer = find_or_create_stripe_customer_for(user)

          return false unless customer

          ActiveRecord::Base.transaction do
            stripe_subscription = if subscriptions?(customer)
                                    customer.subscriptions.data[0]
                                  else
                                    subscribe_customer_to(customer, plan)
                                  end

            subscription = Subscription.new(
              stripe_subscription_params(stripe_subscription, user)
            )

            subscription.save!

            user.subscription = subscription
            user.save!

            subscription
          end
        rescue Stripe::StripeError
          false
        end
      end

      def subscriptions?(stripe_customer)
        stripe_customer.subscriptions.total_count.positive?
      end

      def subscribe_customer_to(stripe_customer, plan = current_plan, opts = {})
        params = {
          plan: plan.id,
          prorate: false,
          trial_period_days: plan.trial_period_days
        }.merge(opts)

        stripe_customer.subscriptions.create(params)
      end

      private

      def stripe_subscription_params(stripe_sub, user)
        {
          stripe_id: stripe_sub.id,
          user_id: user.id,
          trial_end: stripe_sub.trial_end &&
            Time.zone.at(stripe_sub.trial_end).to_datetime,
          trial_start: stripe_sub.trial_start &&
            Time.zone.at(stripe_sub.trial_start).to_datetime,
          current_period_end: Time.zone.at(
            stripe_sub.current_period_end
          ).to_datetime,
          current_period_start: Time.zone.at(
            stripe_sub.current_period_start
          ).to_datetime,
          cancel_at_period_end: stripe_sub.cancel_at_period_end,
          status: stripe_sub.status,
          billing_plan_data: stripe_sub.plan
        }
      end

      def current_plan
        plan_id = StripePlan.find_by(active: true)&.plan_id

        plan_id ||= StripePlan.find_by(
          plan_id: ENV['STRIPE_INDIVIDUAL_PLAN_ID']
        )&.plan_id

        plan_id ||= StripePlan.order(:amount).first&.plan_id

        Stripe::Plan.retrieve(plan_id)
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
  # rubocop:enable Metrics/ClassLength
end
