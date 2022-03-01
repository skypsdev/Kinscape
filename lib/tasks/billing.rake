Stripe.api_key = Global.stripe.secret_key

namespace :billing do
  desc 'Migrates old subscriptions to Stripe powered'
  task migrate_subscriptions: :environment do
    puts 'Deleting old supscriptions...'
    Subscription.destroy_all
    puts '> done'

    Family.all.order(created_at: :asc).each do |family|
      puts '-' * 40
      unless family.connector
        puts "> Warning! Family ##{family.id} has no connector!!!"
        next
      end

      user = family.connector

      if user.subscription
        puts "Skipping #{user.name} as #{user.subscription.stripe_id} present"
        next
      end
      puts "Migrating #{user.name} as #{family.name} connector"

      begin
        customer = \
          Billing::SubscriptionService.find_or_create_stripe_customer_for(user)

        stripe_subscription = \
          if customer.subscriptions.total_count.positive?
            customer.subscriptions.data[0]
          else
            Billing::SubscriptionService.subscribe_customer_to(
              customer
            )
          end

        stripe_subscription.save

        Subscription.create(
          user_id: user.id,
          stripe_id: stripe_subscription.id,
          trial_end: Time.zone.at(stripe_subscription.trial_end).to_datetime,
          trial_start: Time.zone.at(stripe_subscription.trial_start).to_datetime,
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
      rescue StandardError => e
        puts "> Error: #{e.message}"
      end
    end
  end

  desc 'Enables all trial ended users to Stripe powered'
  task enable_trial_ended_subscriptions: :environment do
    users = User.where.not(stripe_id: nil)
    total = users.count

    total_processed = 0

    users.each_with_index do |user, index|
      puts "Processing #{index + 1} of #{total} users"

      stripe_subscription = nil

      begin
        customer = Stripe::Customer.retrieve user.stripe_id

        if customer.subscriptions.total_count.positive?
          stripe_subscription = customer.subscriptions.data[0]
        end
      rescue StandardError => e
        puts "> Error: #{e.message}"
        next
      end

      next if stripe_subscription &&
              %w(past_due canceled).exclude?(stripe_subscription['status'])

      if stripe_subscription && stripe_subscription['status'] == 'past_due'
        stripe_subscription.delete
      end

      user.subscription&.destroy

      total_processed += 1

      puts "Total #{total_processed} subscriptions deleted"
    end
  end

  desc 'Import all Stripe plans to Kinscape'
  task import_stripe_plans: :environment do
    plans = Stripe::Plan.list

    plans.each do |plan|
      stripe_plan = StripePlan.find_or_create_by(plan_id: plan.id)
      stripe_plan.update(
        nickname: plan.nickname,
        currency: plan.currency,
        amount: plan.amount,
        interval: plan.interval,
        trial_period_days: plan.trial_period_days,
        product: ENV['STRIPE_PRODUCT_ID']
      )
    end
  end

  desc 'Move Stripe subscriptions from a plan to another plan'
  task move_subscription_plans: [:environment, :old_plan, :new_plan] do |_t, args|
    exit unless args[:old_plan]
    exit unless args[:new_plan]

    stripe_subscriptions = []
    end_sub = nil

    loop do
      sub_list = Stripe::Subscription.list(
        plan: args[:old_plan],
        limit: 100,
        starting_after: end_sub
      )
      end_sub = sub_list.data.last
      stripe_subscriptions += sub_list.data

      break unless sub_list.has_more
    end

    stripe_subscriptions.each do |subscription|
      Stripe::Subscription.update(
        subscription.id,
        items: [
          {
            id: subscription.items.data[0].id,
            plan: args[:new_plan]
          }
        ]
      )

      puts "Subscription##{subscription.id} has been updated."
    end
  end

  desc 'Update first_name and last_name if user name is null'
  task update_user_name: :environment do
    # User first name and last name
    User.all.each do |user|
      user.update(first_name: 'Test') unless user.first_name
      user.update(last_name: 'Test') unless user.last_name
    end
  end

  desc 'Subscription For Existing User on production with test ENV config'
  task subscription_for_existing_user: :environment do
    puts 'Assign New Subscription (30 Days Free trial + Individual Plan)'

    User.all.each do |user|
      puts "user  -----> #{user.id}"
      break if User.where(email: user.email).count > 1

      begin
        subscription_id = user.subscription&.stripe_id
        if subscription_id.present?
          subscription = Stripe::Subscription.retrieve(subscription_id)
          subscription.delete unless subscription.canceled_at
        end

        user.subscription&.destroy
        Billing::SubscriptionService.subscribe(user)
        # puts "subscription  -----> #{user.id}"
      rescue Stripe::StripeError
        puts "I am rescued.  -----> #{user.id}"
      end

      Billing::SubscriptionService.subscribe(user) if user.subscription.nil?
    end
    puts 'Assign New Subscription (30 Days Free trial + Individual Plan)'
  end
end
