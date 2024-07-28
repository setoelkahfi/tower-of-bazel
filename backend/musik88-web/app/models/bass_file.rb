class BassFile < ApplicationRecord
    belongs_to :audio_file, optional: true
    has_one_attached :source_file
end
