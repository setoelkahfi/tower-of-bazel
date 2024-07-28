class AlterDrumBackingTrack < ActiveRecord::Migration[6.1]
  def change
    add_column :drum_backing_tracks, :status, :integer, default: 0
    add_column :drum_backing_tracks, :status_progress, :integer, default: 0
    add_column :drum_backing_tracks, :views_count, :integer, default: 0
  end
end
