class FixMetaPages < ActiveRecord::Migration[6.1]
  def change
    rename_table :meta_pages, :meta
    add_column :meta, :title, :string
    add_column :meta, :description, :text
    add_column :meta, :locale, :string
  end
end
