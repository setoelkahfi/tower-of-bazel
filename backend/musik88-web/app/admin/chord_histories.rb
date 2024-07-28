ActiveAdmin.register ChordHistory do
  menu priority: 8, parent: 'Music Database'
  permit_params :chord_id, :user_id, :name
  actions :all, except: %i[edit destroy]
  config.clear_action_items!

  index do
    selectable_column
    column :chord
    column :user
    column :name
    column :created_at
    column :updated_at
    actions
  end

  filter :chord
  filter :user
  filter :name
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :chord
      row :user
      row :name
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :chord, include_blank: false, selected: params[:chord_id]
      f.input :user, include_blank: false, selected: params[:user_id]
      f.input :name
      f.input :created_at
      f.input :updated_at
    end
    actions
  end
end
