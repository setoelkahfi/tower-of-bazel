class AddClicksCountToKaraokeFile < ActiveRecord::Migration[6.0]
  def change
    add_column :karaoke_files, :clicks_count, :integer, default: 0
  end
end
