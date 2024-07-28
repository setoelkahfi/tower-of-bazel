class AddIsPublishedToLyrics < ActiveRecord::Migration[6.0]
  def change
    add_column :lyrics, :is_published, :boolean, default: false
  end
end
