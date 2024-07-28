class SongProviderVote < ApplicationRecord
  belongs_to :song_provider
  belongs_to :user

  enum vote_type: %i[up down]

  def as_json(options = {})
    options[:methods] = %i[id voter_gravatar voter_username_or_id]
    super
  end

  def voter_gravatar
    user.gravatar_url
  end

  def voter_username_or_id
    user.username_or_id
  end
end
