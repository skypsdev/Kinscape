class PagesController < ApplicationController
  include HighVoltage::StaticPage

  skip_before_action :require_login, if: proc { params[:id] != 'start' }
  # Temp. remove payment feature
  # before_action :set_plan, only: :show

  def invalid_page
    redirect_to root_path
  end

  private

  def set_plan
    return unless params[:id] == 'pricing'

    @plan = StripePlan.find_by(active: true) || Stripe::Plan.retrieve('basic')
  end
end
