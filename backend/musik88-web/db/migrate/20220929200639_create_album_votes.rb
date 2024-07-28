class CreateAlbumVotes < ActiveRecord::Migration[6.1]
  def change
    create_table :album_votes do |t|
      t.references :user, foreign_key: true
      t.references :album, foreign_key: true

      t.timestamps
    end
  end
end
