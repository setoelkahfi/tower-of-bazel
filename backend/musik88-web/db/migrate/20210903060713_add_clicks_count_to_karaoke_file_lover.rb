class AddClicksCountToKaraokeFileLover < ActiveRecord::Migration[6.0]
  def change
    add_column :karaoke_file_lovers, :clicks_count, :integer
  end
end
