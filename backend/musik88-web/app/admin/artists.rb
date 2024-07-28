ActiveAdmin.register Artist do
  menu priority: 3, parent: 'Music Database'
  permit_params :name, :user_id, :description

  index do
    selectable_column
    column :name
    column :description do |artist|
      strip_tags artist.description.truncate 150
    end
    column 'Albums', max_width: '800px', min_width: '400px' do |artist|
      if artist.album.count.positive?
        artist.album.each_with_index do |album, _index|
          a album.name, href: admin_album_url(album)
          text_node ' | '.html_safe
          a 'edit', href: edit_admin_album_url(album)
          text_node '</br>'.html_safe
        end
        text_node '</br>'.html_safe
      end
      link_to 'Tambah', new_admin_album_path + '?artist_id=' + artist.id.to_s
    end
    column :user
    column :views_count
    actions
  end

  filter :album
  filter :views_count
  filter :name
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :name
      row :user
      row :description do |artist|
        raw artist.description
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :user
      f.input :description, as: :quill_editor
    end
    f.actions
  end
end
