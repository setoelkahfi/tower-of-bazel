class CreateBassBackingTracks < ActiveRecord::Migration[6.1]
  def change
    create_table :bass_backing_tracks do |t|
      t.boolean :is_public

      t.timestamps
    end
  end
end
