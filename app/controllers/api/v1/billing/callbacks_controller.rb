module Api
  module V1
    module Billing
      class CallbacksController < BaseController
        skip_before_action :authenticate_user,
                           :verify_authenticity_token,
                           raise: false
        before_action :store_event

        def invoice_status_changed
          ensure_message_type 'INVOICE_STATUS_CHANGED'

          last_event =
            BillingEvent
            .where(subscription_id: params['vendor_order_id'])
            .where(message_type: params['message_type'])
            .order(timestamp: :asc)
            .last

          if should_prolong_subscription?(last_event)
            ::Billing::SubscriptionService.prolong params['vendor_order_id']
          end

          render nothing: true
        end

        def store_any_event
          render nothing: true
        end

        private

        def should_prolong_subscription?(last_event)
          last_event.payload['invoice_status'] == 'deposited' &&
            last_event.timestamp > params['timestamp']
        end

        def ensure_message_type(message_type)
          return if params['message_type'] == message_type

          render nothing: true, status: 422
        end

        def store_event
          BillingEvent.create!(
            payload: params,
            message_type: params['message_type'],
            subscription_id: params['vendor_order_id'],
            timestamp: params['timestamp']
          )
        end
      end
    end
  end
end
