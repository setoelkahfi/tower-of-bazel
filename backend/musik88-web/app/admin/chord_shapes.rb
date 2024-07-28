ActiveAdmin.register ChordShape do
    menu priority: 7, parent: 'Guitar'
    permit_params :chord_shape_id, :name, :youtube_link, :image_link

    index do
        selectable_column
        column :name
        column :youtube_link
        column :image_link
        actions
    end

    filter :name
    filter :youtube_link
    filter :image_link
    filter :created_at
    filter :updated_at

    show do
        attributes_table do
        row :name
        row :youtube_link
        row :image_link
        row :created_at
        row :updated_at
        end
    end

    form do |f|
        f.inputs do
            f.input :name
            f.input :youtube_link
            f.input :image_link
        end
        actions
    end
end
