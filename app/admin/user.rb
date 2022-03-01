# rubocop:disable Metrics/BlockLength

ActiveAdmin.register User do
  menu label: 'Kinscape Community'
  menu false
  actions :all, except: [:new]

  permit_params :email, :first_name, :last_name, :admin

  config.filters = false
  config.batch_actions = false

  controller do
    actions :all, except: [:show]

    def scoped_collection
      User.joins(:kinships)
          .joins(:families)
          .where(families: { id: Global.admin.family_id })
          .group(:id)
    end
  end

  index title: 'Kinscape Community' do
    column :id
    column :first_name
    column :last_name
    column :email
    column 'Administrator', :admin
    actions
  end

  form title: 'Edit Kinscape Community member' do |f|
    f.semantic_errors
    inputs do
      input :first_name
      input :last_name
      input :email
      input :admin, label: 'Administrator'
    end
    f.actions
  end

  show do
    attributes_table do
      row :first_name
      row :last_name
      row :email
      row :admin
    end
  end
end

# rubocop:enable Metrics/BlockLength
