ActiveAdmin.register User do
  menu priority: 2, parent: 'Users'
  permit_params :email, :username, :name, :instagram, :youtube_channel_id, :about, :password, :password_confirmation,
                :confirmed_at, :confirmation_sent_at

  actions :all

  index do
    selectable_column
    column :email
    column :name
    column :confirmation_sent_at
    column :confirmed_at
    column 'Providers' do |user|
      if user.authorizations.count.positive?
        user.authorizations.each_with_index do |auth, index|
          text_node "#{auth.provider}#{', ' if index != user.authorizations.size - 1}"
        end
        nil
      end
    end
    column :created_at
    column :updated_at
    actions
  end

  filter :email
  filter :name
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :email
      row :username
      row :name
      row :instagram
      row :youtube_channel_id
      row :about
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :username
      f.input :name
      f.input :instagram
      f.input :youtube_channel_id
      f.input :about
      f.input :confirmation_sent_at
      f.input :confirmed_at
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
