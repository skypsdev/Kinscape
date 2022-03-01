class MailerService < ApplicationService
  def initialize(mail_template, params:, deliver_method: :deliver_later)
    @mail_template = mail_template
    @params = params
    @deliver_method = Rails.env.production? ? deliver_method : :deliver_now
  end

  def call
    Mailer.public_send(mail_template, **params).public_send(deliver_method)
  end

  private

  attr_reader :mail_template, :params, :deliver_method
end
