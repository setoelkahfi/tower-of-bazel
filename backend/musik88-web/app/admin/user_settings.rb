ActiveAdmin.register UserSetting do
  menu priority: 3, parent: 'Users'
  actions :all, except: %i[edit update]

  index do
    selectable_column
    column :user
    column :locale
    column :created_at
    column :updated_at
    actions
  end

  filter :user
  filter :locale

  show do
    attributes_table do
      row :user
      row :locale
      row :created_at
      row :updated_at
    end
  end
end
