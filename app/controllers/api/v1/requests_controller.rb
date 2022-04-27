module Api
  module V1
    class RequestsController < BaseController
      def create
        return response_service.render_not_found if kinships.blank?

        ::MailerService.call(
          :send_message,
          params: {
            sender: current_user,
            subject: request_params[:subject],
            message: request_params[:message],
            family: family,
            recipients: recipient_emails
          }
        )
        ::MailerService.call(
          :sender_message_send,
          params: {
            subject: request_params[:subject],
            message: request_params[:message],
            family: family,
            recipient: ["#{current_user.name} <#{current_user.email}>"],
            receiver: kinships.map(&:nickname).join(', ')
          }
        )

        response_service.render_no_content
      end

      private

      def kinships
        @kinships ||= Kinship
                      .includes(:user)
                      .where(id: request_params[:kinships_ids], family: family)
                      .where.not(user_id: nil)
      end

      def family
        @family ||= Family.find(request_params[:family_id])
      end

      def recipient_emails
        kinships.map do |kinship|
          "#{kinship.nickname} <#{kinship.user.email}>"
        end
      end

      def request_params
        params
          .require(:request)
          .permit(:subject, :message, :family_id, kinships_ids: [])
      end
    end
  end
end
