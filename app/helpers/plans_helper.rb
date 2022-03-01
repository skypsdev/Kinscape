module PlansHelper
  def trial_period(plan)
    if (plan.trial_period_days % 30).zero?
      "#{@plan.trial_period_days / 30} months"
    else
      "#{@plan.trial_period_days} days"
    end
  end

  def amount(plan)
    format('%.2f', plan.amount / 100.0)
  end

  def daily_price(plan)
    case plan.interval
    when 'day'
      plan.amount
    when 'week'
      (plan.amount / 7.0).round
    when 'month'
      (plan.amount / 30.0).round
    when 'year'
      (plan.amount / 365.0).round
    end
  end

  def includes_spec(plan)
    if plan.plan_id == ENV['STRIPE_INDIVIDUAL_PLAN_ID']
      t('billing.payment_method.basic_includes')
    else
      t('billing.payment_method.group_includes')
    end
  end

  def storage_size(plan)
    plan.plan_id == ENV['STRIPE_INDIVIDUAL_PLAN_ID'] ? 20 : 200
  end

  def current_plan
    if current_user.guest?
      t('account.plans.guest')
    elsif current_user.subscription&.trialing?
      t('account.plans.trial')
    elsif current_user.subscription&.individual_plan?
      t('account.plans.individual')
    elsif current_user.subscription&.group_plan?
      t('account.plans.group')
    end
  end
end
