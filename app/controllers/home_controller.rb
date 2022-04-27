require 'MailchimpMarketing'

class HomeController < ApplicationController
  skip_before_action :require_login
  before_action :close_for_logged_in

  def index
    redirect_to '/join'
  end

  private

  def close_for_logged_in
    redirect_to stories_path if signed_in?
  end
end
