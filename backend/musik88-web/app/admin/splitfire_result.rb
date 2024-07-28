# TODO: Fix this later
# rubocop:disable Metrics/BlockLength
ActiveAdmin.register SplitfireResult do
  menu priority: 7, parent: 'SplitFire 🔥'
  permit_params :song_id, :locale, :user_id

  index do
    selectable_column
    column :source_file do |file|
      file.source_file.blob.filename
    end
    column :split_audio_file do |file|
      file.audio_file.source_file.blob.filename
    end
    column :onset
    column :length
    actions
  end

  filter :user
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :source_file do |file|
        file.source_file.blob.filename
      end
      row :split_audio_file do |file|
        file.audio_file.source_file.blob.filename
      end
      row :onset
      row :length
      row :created_at
      row :updated_at
    end
  end
end
