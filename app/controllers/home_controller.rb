class HomeController < ApplicationController
  skip_before_action :require_login, only: [:index]
  layout 'home'

  def index
    redirect_to stories_path if signed_in?
    redirect_to join_path if Rails.env.production?
  end
end
