ActiveAdmin.register Chord do
  menu priority: 7, parent: 'Music Database'
  permit_params :song_provider_id, :chord, :user_id, :title

  index do
    selectable_column
    column :title
    column :song_provider
    column :user
    column :status
    column 'Histories' do |chord|
      if chord.chord_histories.count.positive?
        chord.chord_histories.order(updated_at: :desc).each_with_index do |history, _index|
          a history.name, href: admin_chord_history_url(history)
          text_node '</br>'.html_safe
        end
        nil
      else
        # Only add add link if no history.
        link_to 'Tambah',
                "#{new_admin_chord_history_path}?chord_id=#{chord.id}&created_at=#{chord.created_at}&user_id=#{chord.user_id}"
      end
    end
    column :views_count
    actions
  end

  filter :song_provider
  filter :views_count
  filter :lyric
  filter :status
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :title
      row :song_provider
      row :user
      row :status
      row :chord do |chord|
        raw chord.chord
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :title, include_blank: false
      if f.object.new_record?
        f.input :song_provider, include_blank: true, selected: params[:song_provider_id]
      else
        f.input :song_provider, include_blank: true
      end
      f.input :user, include_blank: true
      f.input :status, input_html: { readonly: true, disabled: true }, include_blank: false, selected: 0
      f.input :chord, as: :quill_editor
    end
    actions
  end
end
