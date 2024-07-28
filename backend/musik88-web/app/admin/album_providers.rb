ActiveAdmin.register AlbumProvider do
  menu priority: 3, parent: 'Music Database'
  permit_params :album_id, :user_id

  index do
    selectable_column
    column :name
    column :provider_type
    column :user do |album|
      album.user.email
    end
    column :album
    column :views_count
    actions
  end

  filter :name
  filter :provider_type
  filter :user
  filter :album
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :name
      row :provider_type
      row :user
      row :album
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :album
    end
    f.actions
  end
end
