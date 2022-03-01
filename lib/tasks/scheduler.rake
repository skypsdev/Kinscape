desc 'These tasks are called by the Heroku scheduler add-on'

task release_time_capsules: :environment do
  puts 'Sending time capsule release email notifications...'
  ::Stories::NotificationService.notify_time_capsule_released
  puts 'done.'
end

task weekly_kpi_mailer: :environment do
  puts 'Sending Weekly KPI mailer...'
  Mailer.kpi_weekly.deliver
  puts 'done.'
end

task plan_ending_mailer: :environment do
  # Temporary disabled
  # puts 'Sending Plan ending notification emails...'
  #
  # Subscription.where(status: 'trialing').each do |subscription|
  #   sub_days = subscription.current_period_end.to_date - Time.zone.today
  #
  #   next unless sub_days == 3
  #
  #   Mailer.delay.plan_ending(
  #     recipient: subscription.user,
  #     end_sub_days: I18n.t('mailer.plan_ending.trial_end_sub_days_3'),
  #     end_sub_msg: I18n.t('mailer.plan_ending.end_sub_msg_3')
  #   )
  # end
  #
  # Subscription.where(status: 'active').each do |subscription|
  #   sub_days = subscription.current_period_end.to_date - Time.zone.today
  #
  #   case sub_days
  #   when 10
  #     Mailer.delay.plan_ending(
  #       recipient: subscription.user,
  #       end_sub_days: I18n.t('mailer.plan_ending.active__end_sub_days_10'),
  #       end_sub_msg: I18n.t('mailer.plan_ending.end_sub_msg_10')
  #     )
  #   when 1
  #     Mailer.delay.plan_ending(
  #       recipient: subscription.user,
  #       end_sub_days: I18n.t('mailer.plan_ending.active__end_sub_days_1'),
  #       end_sub_msg: I18n.t('mailer.plan_ending.end_sub_msg_1')
  #     )
  #   end
  # end
  #
  # puts 'done.'
end
