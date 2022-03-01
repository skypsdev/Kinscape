class AdminController < ApplicationController
  http_basic_authenticate_with name: '', password: 'k1nscape'

  def index
    @activated_new_users = activated_users_in_range(30.days.ago..0.days.ago)
    @total_new_users     = new_users_in_range(30.days.ago..0.days.ago)
    @activation_data     = activation_data

    @current_activation =
      activation_percentage(@activated_new_users, @total_new_users).round
  end

  def activation_data
    total_activation = []

    30.times do |i|
      end_date     = (30 - i).days.ago
      time_range   = (60 - i).days.ago..end_date
      total_users  = new_users_in_range(time_range)
      active_users = activated_users_in_range(time_range)
      activation   = activation_percentage(active_users, total_users).round

      total_activation << {
        activation: activation,
        dates: end_date.strftime('%b %-d')
      }
    end

    total_activation
  end

  private

  def activated_users_in_range(time_range)
    User
      .joins(stories: :publications)
      .where('users.created_at' => time_range)
      .distinct
      .count
  end

  def new_users_in_range(time_range)
    User.where('created_at' => time_range).count
  end

  def activation_percentage(active, total)
    return 0 if total.zero?

    active.fdiv(total) * 100
  end
end
