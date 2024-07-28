ActiveAdmin.register Page do
  menu priority: 8, parent: 'Page'
  permit_params :page_slug, :page_content, :locale, :title, :category

  index do
    selectable_column
    column :page_slug
    column :title
    column :page_content do |page|
      strip_tags page.page_content.truncate 150
    end
    column :locale
    column :category
    actions
  end

  filter :page_content
  filter :title
  filter :category
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :page_slug
      row :title
      row :category
      row :page_content do |page|
        raw page.page_content
      end
      row :locale
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :page_slug
      f.input :title
      f.input :category
      f.input :locale
      f.input :page_content, as: :quill_editor
    end
    f.actions
  end
end
