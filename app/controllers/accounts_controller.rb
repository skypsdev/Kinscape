class AccountsController < ApplicationController
  def show
    @families = current_user.families.select(:id, :name)
  end
end
