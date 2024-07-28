require 'action_view'
require 'action_view/helpers'

# Our representation of a song.
# Not to be confused with a song from a provider.
class Song < ApplicationRecord
  include ActionView::Helpers::DateHelper
  include Rails.application.routes.url_helpers

  belongs_to :album, optional: true
  belongs_to :user

  has_many :song_artists, dependent: :destroy
  has_many :artists, through: :song_artists
  has_many :song_chord_plea, dependent: :destroy
  has_many :users, through: :song_chord_plea

  accepts_nested_attributes_for :song_artists, allow_destroy: true

  has_many :lyrics, dependent: :destroy
  has_many :chords, dependent: :destroy

  has_many :comments, as: :commentable

  # Song providers
  has_many :song_providers
  has_many :youtubes, -> { where(provider_type: :youtube) }, class_name: 'SongProvider'
  has_many :spotifies, -> { where(provider_type: :spotify) }, class_name: 'SongProvider'

  # More than one user may upload the same file from a song.
  has_many :audio_file

  has_many :audio_files

  validates_length_of :album, presence: true, allow_blank: false
  validates_length_of :name, presence: true, allow_blank: false
  validates_length_of :description, presence: true, allow_blank: false

  def as_json(options = {})
    options[:methods] = %i[songwriters path type created]
    super
  end

  def title_link
    _title_link = name
    _title_link += " #{album.artists.first.name}" if album&.artists&.first&.present?
    _title_link += " #{album.name}" if album.present?
    _title_link
  end

  def slug
    _slug = name
    _slug += "-#{album.artists.first.name}" if album&.artists&.first&.present?
    _slug += "-#{album.name}" if album.present?
    _slug += "-#{id}"
    _slug.downcase.parameterize
  end

  private

  def songwriters
    artists.as_json(only: %i[id name])
  end

  def created
    "#{time_ago_in_words(created_at)} #{I18n.t('ago')}"
  end

  def path
    song_detail_path(slug)
  end

  def type
    I18n.t(self.class.name)
  end
end
