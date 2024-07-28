class UserSetting < ApplicationRecord
  belongs_to :user

  enum locale: I18n.available_locales

  enum model: %i[
    2stems
    4stems
    5stems
  ]

  enum frequency: %i[
    11kHz
    16kHz
  ]

  def update_settings(type, value)
    value = ActiveModel::Type::Boolean.new.cast(value)
    case type
    when 'sync_spotify'
      update(sync_spotify: value)
    when 'allowed_use_google_token'
      update(allowed_use_google_token: value)
    when 'allowed_use_spotify_token'
      update(allowed_use_spotify_token: value)
    when 'locale'
      update(locale: value)
    end
  end
end
