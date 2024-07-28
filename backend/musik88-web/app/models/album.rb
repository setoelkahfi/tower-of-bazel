require 'action_view'
require 'action_view/helpers'

class Album < ApplicationRecord
  include ActionView::Helpers::DateHelper
  include Rails.application.routes.url_helpers

  has_many :album_artists, dependent: :destroy
  has_many :artists, -> { order 'album_artists.primary desc, artists.name asc' }, through: :album_artists
  accepts_nested_attributes_for :album_artists, allow_destroy: true
  has_many :songs

  has_many :comments, as: :commentable

  has_many :album_vote, dependent: :destroy
  has_many :users, through: :album_vote

  belongs_to :user

  validates_length_of :name, presence: true, allow_blank: false
  validates_length_of :description, presence: true, allow_blank: false

  def slug
    "#{name}-#{artists.collect(&:name).join('-')}-#{id}".downcase.parameterize
  end

  def as_json(options = {})
    options[:methods] = %i[path type created]
    super
  end

  private

  def type
    I18n.t(self.class.name)
  end

  def path
    album_detail_path(slug)
  end

  def created
    "#{time_ago_in_words(created_at)} #{I18n.t('ago')}"
  end
end
