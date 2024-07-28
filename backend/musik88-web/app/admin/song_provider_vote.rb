ActiveAdmin.register SongProviderVote do
  menu priority: 6, parent: 'Music Database'
  permit_params :user_id

  index do
    selectable_column
    column :user do |vote|
      vote.user.email
    end
    column :song_provider
    column :vote_type
    actions
  end

  filter :user
  filter :song_provider
  filter :vote_type
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :user
      row :song_provider
      row :vote_type
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :song_provider
      f.input :user
      f.input :vote_type
    end
    f.actions
  end
end
