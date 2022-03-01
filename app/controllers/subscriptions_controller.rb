class SubscriptionsController < ApplicationController
  skip_before_action :authenticate_user,
                     :verify_authenticity_token,
                     :require_login,
                     only: [:webhook],
                     raise: false
  def cancel
    if Billing::SubscriptionService.cancel_for(current_user)
      flash[:success] = t('subscriptions.messages.canceled')
    else
      flash[:error] = t('subscriptions.errors.standard')
    end

    redirect_to account_path
  end

  def resume
    if Billing::SubscriptionService.resume_for(current_user)
      flash[:success] = t('subscriptions.messages.resumed')
    else
      flash[:error] = t('subscriptions.errors.standard')
    end

    redirect_to account_path
  end

  def renew
    if Billing::SubscriptionService.renew_for(current_user)
      ::MailerService.call(:thank_you_for_subscribe, params: { recipient: current_user })
      flash[:success] = t('subscriptions.messages.renewed')
    else
      flash[:error] = t('subscriptions.errors.standard')
    end

    redirect_to account_path
  rescue Billing::SubscriptionServiceError => e
    flash[:error] = e.message
    redirect_to account_path
  end

  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, Global.stripe.endpoint_secret
      )

      case event.type
      when 'customer.deleted'
        User.find_by!(stripe_id: event.data.object.id)
            .update_attribute(stripe_id: nil)
      when 'customer.subscription.deleted'
        Billing::SubscriptionService.delete(event.data.object.id)
      when 'customer.subscription.updated',
           'customer.subscription.created'
        Billing::SubscriptionService.update(event.data.object)
      when 'plan.created',
           'plan.updated'
        Billing::PlanService.update(event.data.object)
      when 'plan.deleted'
        Billing::PlanService.delete(event.data.object.id)
      when 'invoice.payment_succeeded'
        if event.data.object.amount_paid.positive?
          customer = User.find_by(stripe_id: event.data.object.customer)
          ::MailerService.call(:thank_you_for_subscribe, params: { recipient: customer })

          inform_plan_renewal(customer)
        end
      end

      render json: { status: 200 }
    rescue JSON::ParserError
      render json: { status: 400, error: 'Invalid payload' }
    rescue Stripe::SignatureVerificationError
      render json: { status: 422, error: 'Invalid signature' }
    rescue StandardError => e
      render json: { status: 422, error: e.message }
    end
  end

  # TODO-RUBOCOP
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  def inform_plan_renewal(subscriber)
    if subscriber.subscription&.individual_plan?
      families = subscriber.owned_families.uniq
    elsif subscriber.subscription&.group_plan?
      families = subscriber.families.uniq
    end

    if families.count > 1
      family_names = "#{families.pluck(:name).join(', ')}, families"
    elsif families.count == 1
      family_names = "#{families.first.name} family"
    end

    recipients = []

    families.each do |family|
      family.users.each do |user|
        recipients << user unless user == subscriber
      end
    end

    recipients.uniq.each do |recipient|
      ::MailerService.call(
        :paid_for_subscription,
        params: {
          subscriber: subscriber,
          recipient: recipient,
          family_names: family_names
        }
      )
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
end
