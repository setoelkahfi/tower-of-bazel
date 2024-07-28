class AddViewsCount < ActiveRecord::Migration[5.2]
  def change
    add_column :artists, :views_count, :integer, default: 0
    add_column :albums, :views_count, :integer, default: 0
    add_column :songs, :views_count, :integer, default: 0
    add_column :lyrics, :views_count, :integer, default: 0
  end
end
