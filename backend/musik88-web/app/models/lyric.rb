class Lyric < ApplicationRecord
  belongs_to :song
  belongs_to :user

  has_many :lyric_vote, dependent: :destroy
  has_many :users, through: :lyric_vote

  has_many :comments, as: :commentable

  validates :lyric, presence: true

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

  def title_link
    song.title_link
  end

  def slug
    "#{song.slug}-#{id}"
  end

end
