ActiveAdmin.register JavaneseGendingNotation do
  menu priority: 9, parent: 'Javanese Gending'
  permit_params :name, :notation, :user_id, :javanese_gending_id, :rich_format
  json_editor

  index do
    selectable_column
    column :name
    column :notation do |gending|
      strip_tags gending.notation.truncate 150
    end
    column :rich_format do |gending|
      gending.rich_format.nil? ? 'No ⛔️' : 'Yes ✅'
    end
    column :javanese_gending
    column :user
    column :views_count
    actions
  end

  show do
    attributes_table do
      row :name
      row :javanese_gending
      row :user
      row :notation do |gending|
        raw gending.notation
      end
      row :rich_format
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      if f.object.new_record?
        f.input :javanese_gending, include_blank: false, selected: params[:javanese_gending_id]
      else
        f.input :javanese_gending, include_blank: false
      end
      f.input :rich_format, as: :json
      f.input :user
      f.input :notation, as: :quill_editor
    end
    f.actions
  end
end
