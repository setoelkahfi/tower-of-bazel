# frozen_string_literal: true

require 'action_view'
require 'action_view/helpers'

# Notation of a Javanese gending
# Not to be confused with JavaneseGending itself

class JavaneseGendingNotation < ApplicationRecord
  include ActionView::Helpers::DateHelper
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :javanese_gending
  has_many :comments, as: :commentable
  has_many :gending_notation_vote, dependent: :destroy
  has_many :users, through: :gending_notation_vote

  def link_title
    name.to_s.downcase
  end

  def slug
    "#{name}-#{id}".downcase.parameterize
  end

  def user_or_nowhereman
    user || User.find_by(username: 'nowhereman')
  end

  def as_json(options = {})
    options[:methods] = %i[path type created]
    super
  end

  def path
    javanese_gending_gamelan_notation_detail_path(slug)
  end

  def created
    "#{time_ago_in_words(created_at)} #{I18n.t('ago')}"
  end

  def as_json_packed
    as_json(only: %i[id name rich_format])
  end

  private

  def type
    I18n.t(self.class.name)
  end
end
