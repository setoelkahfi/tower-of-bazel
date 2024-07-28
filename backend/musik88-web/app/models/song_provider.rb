# frozen_string_literal: true

require 'action_view'
require 'action_view/helpers'

class SongProvider < ApplicationRecord
  include ActionView::Helpers::DateHelper
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :song
  belongs_to :album_provider, optional: true
  belongs_to :artist_provider, optional: true
  # Should only has one chord. All contribution should be done through one chord.
  has_one :chord
  has_one :audio_file

  has_many :song_provider_vote, dependent: :destroy
  has_many :voters, through: :song_provider_vote, source: :user

  enum provider_type: %i[
    spotify
    youtube
  ]

  enum status: %i[
    published
    unpublished
  ]

  def as_json(options = {})
    options[:methods] = %i[audio_file path type provider_id provider_type created]
    super
  end

  def type
    I18n.t(self.class.name)
  end

  def slug
    "#{name}-#{id}".downcase.parameterize
  end

  def path
    song_bridge_path(slug)
  end

  def provider_url
    case provider_type
    when 'spotify'
      "https://open.spotify.com/track/#{provider_id}"
    when 'youtube'
      "https://www.youtube.com/watch?v=#{provider_id}"
    end
  end

  def created
    "#{time_ago_in_words(created_at)} #{I18n.t('ago')}"
  end
end
