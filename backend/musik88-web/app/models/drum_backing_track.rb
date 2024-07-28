class DrumBackingTrack < ApplicationRecord
  belongs_to :audio_file
  has_one_attached :source_file

  # Enum, enum everywhere...
  enum status: %i[
    processing
    done
  ]
end
