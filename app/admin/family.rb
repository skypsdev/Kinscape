ActiveAdmin.register Family do
  menu false
  actions :all, except: [:new]
  permit_params :name
  config.batch_actions = false
  config.filters = false

  controller do
    actions :all, except: [:show]
  end

  index do
    column :id
    column 'Family', :name
    actions
  end

  form do |f|
    f.semantic_errors
    inputs :name
    f.actions
  end

  show do
    attributes_table do
      row :name
    end
  end
end
