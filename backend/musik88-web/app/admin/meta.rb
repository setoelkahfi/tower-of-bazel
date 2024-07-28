ActiveAdmin.register Meta do
  menu priority: 8, parent: 'Page'
  permit_params :home, :title, :description, :locale

  index do
    selectable_column
    column :home
    column :title
    column :description
    column :locale
    actions
  end

  filter :home
  filter :title
  filter :description
  filter :locale
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :home
      row :title
      row :description
      row :locale
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :home
      f.input :title
      f.input :description
      f.input :locale
    end
    f.actions
  end
end
