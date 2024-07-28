require 'action_view'
require 'action_view/helpers'

class JavaneseGending < ApplicationRecord
  include ActionView::Helpers::DateHelper
  include Rails.application.routes.url_helpers

  belongs_to :user
  has_many :javanese_gending_notation
  has_many :comments, as: :commentable
  has_many :gending_vote, dependent: :destroy
  has_many :users, through: :gending_vote

  def user_or_nowhereman
    user || User.find_by(username: 'nowhereman')
  end

  def slug
    "#{name.downcase.parameterize}-#{id.to_s}"
  end

  def as_json(options = {})
    options[:methods] = %i[path type created]
    super
  end

  private

  def created
    "#{time_ago_in_words(created_at)} #{I18n.t('ago')}"
  end

  def path
    javanese_gending_detail_path(slug)
  end

  def type
    I18n.t(self.class.name)
  end
end
