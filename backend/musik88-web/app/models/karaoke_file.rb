class KaraokeFile < ApplicationRecord
  belongs_to :audio_file
  has_one_attached :source_file

  # User can only love the file once
  has_many :karaoke_file_lover, dependent: :destroy
  has_many :users, through: :karaoke_file_lover
end
