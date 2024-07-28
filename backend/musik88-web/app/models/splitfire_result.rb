# frozen_string_literal: true

class SplitfireResult < ApplicationRecord
  belongs_to :audio_file

  has_one_attached :source_file
end
