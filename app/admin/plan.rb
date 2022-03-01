# rubocop:disable Metrics/BlockLength
ActiveAdmin.register_page 'Plan' do
  menu priority: 1, label: proc { 'Stripe Plan' }

  content do
    columns do
      column do
        stripe_plans = StripePlan.all

        render partial: 'admin/plans/plan', locals: { plans: stripe_plans }
      end
    end
  end

  page_action :new do
    render 'admin/plans/new', layout: 'active_admin'
  end

  page_action :create, method: :post do
    stripe_plan = Billing::PlanService.stripe_create(params)

    plan = Billing::PlanService.update(stripe_plan)

    if plan.update(active: params[:active])
      redirect_to admin_plan_path
    else
      flash[:error] = 'A plan already used'

      redirect_to admin_plan_edit_path(id: plan.id)
    end
  rescue Stripe::StripeError
    flash[:error] = 'Failed to create a new stripe plan'

    render 'admin/plans/new', layout: 'active_admin'
  end

  page_action :edit do
    @plan = StripePlan.find_by(plan_id: params[:id])

    render 'admin/plans/edit', layout: 'active_admin'
  end

  page_action :update, method: :post do
    @plan = StripePlan.find_by(plan_id: params[:id])
    stripe_plan = Billing::PlanService.stripe_update(params)
    @plan = Billing::PlanService.update(stripe_plan)

    if @plan.update(active: params[:active])
      redirect_to admin_plan_path
    else
      flash[:error] = 'A plan already used'

      render 'admin/plans/edit', layout: 'active_admin'
    end
  rescue Stripe::StripeError
    flash[:error] = 'Failed to update this stripe plan'

    render 'admin/plans/edit', layout: 'active_admin'
  end

  page_action :destroy, method: :delete do
    Billing::PlanService.stripe_delete(params[:id])
    Billing::PlanService.delete(params[:id])

    redirect_to admin_plan_path
  rescue Stripe::StripeError
    flash[:error] = 'Failed to delete the stripe plan'

    redirect_to admin_plan_path
  end

  action_item :new, priority: 0 do
    link_to 'New Plan', admin_plan_new_path
  end
end
# rubocop:enable Metrics/BlockLength
