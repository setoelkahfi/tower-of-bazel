ActiveAdmin.register Lyric do
  menu priority: 6, parent: 'Music Database'
  permit_params :song_id, :lyric, :locale, :user_id

  index do
    selectable_column
    column :lyric do |lyric|
      strip_tags lyric.lyric.truncate 150
    end
    column :song
    column :user
    column :views_count
    actions
  end

  filter :song
  filter :views_count
  filter :lyric
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :song
      row :user
      row :lyric do |song|
        raw song.lyric
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      if f.object.new_record?
        f.input :song, include_blank: false, selected: params[:song_id]
      else
        f.input :song, include_blank: false
      end
      f.input :user, include_blank: false
      f.input :lyric, :input_html => { :class => "tinymce", :style => 'width: auto' }
    end
    actions
  end
end
