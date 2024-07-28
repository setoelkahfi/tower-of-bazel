class ChordHistory < ApplicationRecord
  belongs_to :chord
  belongs_to :user
  validates_length_of :name, presence: true, allow_blank: false
end
