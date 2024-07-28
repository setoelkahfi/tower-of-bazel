# Fix this later
# rubocop:disable Metrics/ClassLength
class AudioFile < ApplicationRecord
  enum status: %i[
    downloading
    splitting
    done
  ]

  belongs_to :song_provider

  has_many  :splitfire_results,   dependent: :destroy
  has_one   :bass_backing_track,  dependent: :destroy # Deprecated
  has_one   :karaoke_file,        dependent: :destroy

  has_one   :bass_backing_track_file,   dependent: :destroy
  has_one   :guitar_backing_track_file, dependent: :destroy
  has_one   :drum_backing_track,        dependent: :destroy

  # Internal use
  has_many  :vocal_file,  dependent: :nullify
  has_many  :bass_file,   dependent: :nullify
  has_many  :drum_file,   dependent: :nullify
  has_many  :other_file,  dependent: :nullify
  # END

  has_many :comments, as: :commentable

  # Split processig status
  has_one :audio_file_split_status, dependent: :destroy
  # END

  # Bass64 processig status
  has_one :audio_file_bass64_status, dependent: :destroy
  # END

  # KaroKowe processig status
  has_one :audio_file_karokowe_status, dependent: :destroy
  # END

  # KaroKowe processig status
  has_one :audio_file_bonzo_status, dependent: :destroy
  # END

  # ActiveStorage attachments
  has_one_attached :source_file

  def is_valid_row?
    source_file.attached? || (!youtube_video_url.nil? && !youtube_video_id.nil?)
  end

  def is_in_progress?
    !audio_file_split_status.nil? && (audio_file_split_status.processing? || audio_file_split_status.youtube_converting?)
  end

  def should_show_result_content?
    audio_file_split_status.youtube_converting? || splitfire_results.count.positive?
  end

  def output_filename
    output = ''
    output = '<i class="icon-youtube"></i> ' if !youtube_video_url.nil? && !youtube_video_id.nil?

    if audio_file_split_status.youtube_converting?
      output += 'Converting YouTube video to mp3'
    elsif source_file.attached?
      output += source_file.blob.filename.to_s
    end

    output
  end

  # ActiveAdmin title. See: https://stackoverflow.com/a/8429960/1137814
  def name
    song_provider&.name
  end

  def youtube_thumbnail
    "https://img.youtube.com/vi/#{song_provider.provider_id}/mqdefault.jpg"
  end

  def splitfire_link
    "https://#{host}/@#{user.username_or_id}/#{source_file.filename.to_s.downcase.parameterize}-#{id}"
  end

  def splitfire_karaoke_link
    "https://#{host}/@#{user.username_or_id}/#{source_file.filename.to_s.downcase.parameterize}-#{id}/karaoke-version"
  end

  def splitfire_guitar_backing_track_link
    "https://#{host}/@#{user.username_or_id}/#{source_file.filename.to_s.downcase.parameterize}-#{id}/guitar-backing-track-version"
  end

  def splitfire_bass_backing_track_link
    "https://#{host}/@#{user.username_or_id}/#{source_file.filename.to_s.downcase.parameterize}-#{id}/bass-backing-track-version"
  end

  def splitfire_drum_backing_track_link
    "https://#{host}/@#{user.username_or_id}/#{source_file.filename.to_s.downcase.parameterize}-#{id}/drum-backing-track-version"
  end

  def backing_track_slug
    "#{source_file.filename.to_s.downcase.parameterize}-#{id}"
  end

  def karaoke_title
    I18n.t('song_karaoke_title', filename: source_file.filename)
  end

  def guitar_backing_track_title
    "#{source_file.filename} Guitar Backing Track" # TODO: Localize
  end

  def bass_backing_track_title
    "#{source_file.filename} Bass Backing Track" # TODO: Localize
  end

  def drum_backing_track_title
    "#{source_file.filename} Drum Backing Track" # TODO: Localize
  end

  def bass_file
    splitfire_results.find do |result|
      result.source_file.filename.to_s.start_with?('bass')
    end
  end

  def vocals_file
    splitfire_results.find do |result|
      result.source_file.filename.to_s.start_with?('vocals')
    end
  end

  def drums_file
    splitfire_results.find do |result|
      result.source_file.filename.to_s.start_with?('drums')
    end
  end

  def other_file
    splitfire_results.find do |result|
      result.source_file.filename.to_s.start_with?('other')
    end
  end

  def piano_file
    splitfire_results.find do |result|
      result.source_file.filename.to_s.start_with?('piano')
    end
  end

  def attached?
    source_file.attached?
  end

  def as_json(options = {})
    options[:methods] = [:name]
    super
  end

  def as_json_packed
    as_json(only: %i[id status])
  end

  private

  def host
    Rails.env.production? ? 'splitfire.ai' : 'localhost:3002'
  end
end
