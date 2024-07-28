require 'action_view'
require 'action_view/helpers'

class Artist < ApplicationRecord
  include ActionView::Helpers::DateHelper
  include Rails.application.routes.url_helpers

  has_many :album_artists
  has_many :album, through: :album_artists
  accepts_nested_attributes_for :album_artists

  belongs_to :user

  has_many :comments, as: :commentable

  has_many :artist_vote, dependent: :destroy
  has_many :users, through: :artist_vote

  validates_length_of :name, presence: true, allow_blank: false
  validates_length_of :description, presence: true, allow_blank: false

  def as_json(options = {})
    options[:methods] = %i[path type created]
    super
  end

  def slug
    "#{name}-#{id}".downcase.parameterize
  end

  private

  def type
    I18n.t(self.class.name)
  end

  def path
    artist_detail_path(slug)
  end

  def created
    "#{time_ago_in_words(created_at)} #{I18n.t('ago')}"
  end
end
