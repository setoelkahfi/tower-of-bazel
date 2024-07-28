ActiveAdmin.register Album do
  menu priority: 4, parent: 'Music Database'
  permit_params :name, :description, :user_id, :locale, album_artists_attributes: %i[id artist_id primary _destroy]

  index do
    selectable_column
    column :name
    column :description do |album|
      strip_tags album.description.truncate 150
    end
    column 'Artists' do |album|
      if album.artists.count.positive?
        album.artists.each_with_index do |artist, _index|
          a artist.name, href: admin_artist_url(artist)
          text_node ' | '.html_safe
          a 'edit', href: edit_admin_artist_url(artist)
          text_node '</br>'.html_safe
        end
        nil
      end
    end
    column 'Songs' do |album|
      if album.songs.count.positive?
        album.songs.each_with_index do |song, _index|
          a song.name, href: admin_song_url(song)
          text_node ' | '.html_safe
          a 'edit', href: edit_admin_song_url(song)
          text_node '</br>'.html_safe
        end
        text_node '</br>'.html_safe
      end
      link_to 'Tambah', "#{new_admin_song_path}?album_id=#{album.id.to_s}"
    end
    column :user
    column :views_count
    actions
  end

  filter :artists
  filter :songs
  filter :views_count
  filter :name
  filter :description
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :name
      row :description do |album|
        raw album.description
      end
      row :user
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.has_many :album_artists, allow_destroy: true, new_record: 'Tambah Artis' do |a|
        a.input :artist, include_blank: false
        a.input :primary
      end
    end
    f.inputs do
      f.input :name
      f.input :user
      f.input :description, as: :quill_editor
    end
    f.actions
  end
end
