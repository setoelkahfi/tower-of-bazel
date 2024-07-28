ActiveAdmin.register Comment, as: 'ContentComment' do
  menu priority: 4, parent: 'Music Database'
  actions :all, except: %i[new]

  index do
    selectable_column
    column :user
    column :body
    column :commentable_type
    column :commentable_id
    actions
  end

  filter :user
  filter :body
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :user
      row :body
      row :commentable_type
      row :created_at
      row :updated_at
    end
  end
end
