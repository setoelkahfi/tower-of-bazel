class CreateSongProviderVotes < ActiveRecord::Migration[6.1]
  def change
    create_table :song_provider_votes do |t|
      t.references :song_provider, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :vote_type, default: 0

      t.timestamps
    end
  end
end
