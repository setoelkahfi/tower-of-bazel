class BassBackingTrack < ApplicationRecord
  belongs_to :audio_file
  has_one_attached :source_file
end
