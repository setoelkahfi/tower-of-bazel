require 'action_view'
require 'action_view/helpers'

class Chord < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :user, optional: true
  belongs_to :song_provider, optional: true
  validates_length_of :chord, minimum: 10, presence: true, allow_blank: false
  validates_length_of :title, presence: true, allow_blank: false

  has_many :chord_vote, dependent: :destroy
  has_many :users, through: :chord_vote
  has_many :chord_histories, dependent: :destroy

  has_many :comments, as: :commentable

  # Enum, enum everywhere...
  enum status: [
    :pending,             # Freshly submitted.
    :approved,            # Approved by the community.
    :deleted              # To be deleted.
  ]

  def status_symbol
    pending? ? 'bi-clock' : 'bi-check2-circle'
  end

  def status_color
    pending? ? 'text-warning' : 'text-success'
  end

  def user_or_nowhereman
    user || User.find_by(username: 'nowhereman')
  end

  def link_title
    if song_provider.present?
      song_provider.name.to_s
    else
      title
    end
  end

  def slug
    slug = if song_provider.present?
             "#{song_provider.name}-#{id}"
           else
             "#{title}-#{id}"
           end
    slug.downcase.parameterize
  end

  def path
    guitar_chord_detail_path(slug)
  end

  # ActiveAdmin title. See: https://stackoverflow.com/a/8429960/1137814
  def name
    song_provider.present? ? song_provider.name : title
  end
end
