ActiveAdmin.register Authorization do
  menu priority: 2, parent: 'Users'
  permit_params :onboarding_status

  actions :all

  index do
    selectable_column
    column :user
    column :provider
    column :uid
    column :onboarding_status
    column :created_at
    column :updated_at
    actions
  end

  filter :user
  filter :provider
  filter :uid
  filter :onboarding_status

  show do
    attributes_table do
      row :user
      row :provider
      row :uid
      row :onboarding_status
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :user
      f.input :provider
      f.input :uid
      f.input :onboarding_status
    end
    f.actions
  end
end
