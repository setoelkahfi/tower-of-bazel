class User < ApplicationRecord   # rubocop:disable Metrics/ClassLength
  # Virtual attribute to skip password validation while saving new user from
  # a wallet connection.
  attr_accessor :skip_password_validation

  has_merit

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable,
         :registerable,
         :confirmable,
         :recoverable,
         :rememberable,
         :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  before_save { email.downcase! }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  devise :invitable, :omniauthable, omniauth_providers: %i[facebook spotify google_oauth2 apple]

  has_many :chords, dependent: :destroy
  has_many :lyrics, dependent: :destroy
  has_many :songs, dependent: :destroy
  has_many :albums, dependent: :destroy
  has_many :artists, dependent: :destroy
  has_many :javanese_gendings, dependent: :destroy
  has_many :comments, dependent: :delete_all

  # Invitable
  has_many :invitees, class_name: 'User', foreign_key: :invited_by_id

  scope :all_public, -> { where(is_private: false).all }

  has_many :active_relationships, class_name: 'Relationship',
                                  foreign_key: 'follower_id',
                                  dependent: :destroy
  has_many :passive_relationships, class_name: 'Relationship',
                                   foreign_key: 'followed_id',
                                   dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  has_many :authorizations, dependent: :destroy

  has_many :song_chord_pleas, dependent: :destroy
  has_many :javanese_gending_notations, dependent: :destroy

  has_one :user_setting, dependent: :destroy
  has_many :wallets, dependent: :destroy

  has_many :comments, as: :commentable

  # Follows a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # Unfollows a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  # Returns the hash digest of the given string.
  def self.digest(string)
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest
  def authenticated?(remember_token)
    return false if remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Omniauth helpers
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session['devise.facebook_data'] && session['devise.facebook_data']['extra']['raw_info'] && user.email.blank?
        user.email = data['email']
      end
    end
  end

  def self.from_omniauth(auth)
    return_user = where(email: auth.info.email).first
    return_user ||= create do |user|
      user.name = auth.info.name
      user.email = auth.info.email
    end
    save_or_update_provider(return_user, auth)
    return_user
  end

  def self.from_omniauth_web3(auth, pubkey_email)
    return_user = where(email: pubkey_email).first
    # Throw error if we could not find user
    raise 'User not found' if return_user.nil?

    save_or_update_provider(return_user, auth)
    return_user
  end

  def spotify
    authorizations.find_by(user_id: id, provider: 'spotify')
  end

  def google
    authorizations.find_by(user_id: id, provider: 'google_oauth2')
  end

  # General helpers

  def email_client
    email.split('@').last
  end

  def need_onboarding?
    username.presence.nil? || need_onboarding_spotify? || need_onboarding_google?
  end

  def need_onboarding_spotify?
    (spotify.nil? || spotify&.pending?)
  end

  def need_onboarding_google?
    (google.nil? || google&.pending?)
  end

  def as_json(options = {})
    options[:methods] = %i[gravatar_url followers_count following_count]
    super
  end

  def as_json_packed
    as_json(only: %i[id username name about])
  end

  def followers_count
    followers.size
  end

  def following_count
    following.size
  end

  def gravatar_url
    gravatar_id = Digest::MD5.hexdigest(email.downcase)
    "https://secure.gravatar.com/avatar/#{gravatar_id}"
  end

  def username_or_id
    username.presence ? username : id
  end

  def username_or_name
    username.presence ? username : name
  end

  def splitfire_link(item)
    "#{ENV['SF_HOST']}/@#{username_or_id}/#{item.source_file.filename.to_s.downcase.parameterize}-#{item.id}"
  end

  def splitfire_profile_link
    "#{ENV['SF_HOST']}/@#{username_or_id}"
  end

  def verified?
    %w[seto splitfire bonzo karokowe bass64 ahmad yovie nowhereman].include? username
  end

  def reviewer?
    verified?
  end

  def self.save_or_update_provider(user, auth)
    authorization = user.authorizations.find_by(provider: auth.provider, uid: auth.uid)
    authorization ||= Authorization.new(user_id: user.id, provider: auth.provider, uid: auth.uid)
    authorization.update_token(auth.credentials.token, auth.credentials.refresh_token)
  end

  protected

  # Disable password for wallet connection

  def password_required?
    return false if skip_password_validation

    super
  end
end
