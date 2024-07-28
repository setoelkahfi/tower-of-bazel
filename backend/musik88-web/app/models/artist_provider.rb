require 'action_view'
require 'action_view/helpers'

class ArtistProvider < ApplicationRecord
  include ActionView::Helpers::DateHelper
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :artist, optional: true

  enum provider_type: %i[
    spotify
  ]

  def as_json(options = {})
    options[:methods] = %i[path type created]
    super
  end

  def type
    I18n.t(self.class.name)
  end

  def slug
    "#{name}-#{id}".downcase.parameterize
  end

  def path
    artist_bridge_path(slug)
  end

  def provider_url
    "https://open.spotify.com/artist/#{provider_id}"
  end

  def created
    "#{time_ago_in_words(created_at)} #{I18n.t('ago')}"
  end
end
