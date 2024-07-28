ActiveAdmin.register SongProvider do
  menu priority: 5, parent: 'Music Database'
  permit_params :user_id, :status

  index do
    selectable_column
    column :name
    column :provider_type
    column :user do |song|
      song.user.email
    end
    column :song
    column :status
    column :views_count
    actions
  end

  filter :name
  filter :provider_type
  filter :user
  filter :song
  filter :status
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :name
      row :provider_type
      row :album_provider
      row :artist
      row :status
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :song
      f.input :status
    end
    f.actions
  end
end
