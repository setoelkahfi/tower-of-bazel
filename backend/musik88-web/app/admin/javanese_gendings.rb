ActiveAdmin.register JavaneseGending do
  menu priority: 8, parent: 'Javanese Gending'
  permit_params :name, :description, :notation, :user_id

  index do
    selectable_column
    column :name
    column 'NEW Notation' do |gending|
      if gending.javanese_gending_notation.count.positive?
        gending.javanese_gending_notation.each_with_index do |notation, _index|
          a "#{notation.name} #{notation.rich_format.nil? ? 'No ⛔️' : 'Yes ✅'}",
            href: admin_javanese_gending_notation_url(notation)
          text_node ' | '.html_safe
          a 'edit', href: edit_admin_javanese_gending_notation_url(notation)
          text_node '</br>'.html_safe
        end
        nil
      end
      link_to 'Tambah', new_admin_javanese_gending_notation_path(javanese_gending_id: gending.id.to_s)
    end
    column :description do |gending|
      strip_tags gending.description.truncate 150
    end
    column :user
    column :views_count
    actions
  end

  show do
    attributes_table do
      row :name
      row :notation
      row :user
      row :description do |gending|
        raw gending.description
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
      f.input :notation, as: :quill_editor
    end
    f.actions
  end
end
