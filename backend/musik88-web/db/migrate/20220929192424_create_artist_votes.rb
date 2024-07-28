class CreateArtistVotes < ActiveRecord::Migration[6.1]
  def change
    create_table :artist_votes do |t|
      t.references :user, foreign_key: true
      t.references :artist, foreign_key: true

      t.timestamps
    end
  end
end
