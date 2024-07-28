class LyricSynch < ApplicationRecord
  belongs_to :audio_file
  belongs_to :user
end
