class ChangeMetaTableLocaleColumnNames < ActiveRecord::Migration[6.0]
  def change
    rename_column :meta_pages, :title_id, :'title_id-id'
    rename_column :meta_pages, :title_sv, :'title_sv-se'
    rename_column :meta_pages, :description_id, :'description_id-id'
    rename_column :meta_pages, :description_sv, :'description_sv-se'
  end
end
