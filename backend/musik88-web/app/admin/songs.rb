ActiveAdmin.register Song do
  menu priority: 5, parent: 'Music Database'
  permit_params :album_id, :name, :user_id, :description, :locale,
                song_artists_attributes: %i[id artist_id primary _destroy]

  index do
    selectable_column
    column :name
    column :description do |song|
      strip_tags song.description.truncate 150
    end
    column :album
    column 'Lyrics' do |song|
      if song.lyrics.count.positive?
        song.lyrics.each_with_index do |lyric, index|
          a "V #{(index + 1).to_s}", href: admin_lyric_url(lyric)
          text_node ' '.html_safe
          a 'Edit', href: edit_admin_lyric_url(lyric)
          text_node '</br>'.html_safe
        end
        nil
      else
        link_to 'Add', "#{new_admin_lyric_path}?song_id=#{song.id.to_s}"
      end
    end
    column :user
    column :views_count
    actions
  end

  filter :album
  filter :artists
  filter :views_count
  filter :name
  filter :description
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :name
      row :user
      row :description do |song|
        raw song.description
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.has_many :song_artists, heading: 'Artist(s)',
                                allow_destroy: true,
                                new_record: 'Tambah Artis' do |a|
        a.input :artist
        a.input :primary
      end
    end
    f.inputs do
      if f.object.new_record?
        f.input :album, include_blank: false, selected: params[:album_id]
      else
        f.input :album, include_blank: false
      end
      f.input :user, include_blank: false
      f.input :name
      f.input :description, as: :quill_editor
    end
    f.actions
  end
end
