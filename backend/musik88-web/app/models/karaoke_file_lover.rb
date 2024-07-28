class KaraokeFileLover < ApplicationRecord
  belongs_to :karaoke_file
  belongs_to :user
end
