class SongChordPlea < ApplicationRecord
  belongs_to :song
  belongs_to :user
end
