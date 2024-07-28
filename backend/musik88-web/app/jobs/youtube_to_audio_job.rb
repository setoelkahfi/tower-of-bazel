# frozen_string_literal: true

# Convert YouTube video to audio.
class YoutubeToAudioJob < ApplicationJob
  queue_as :default

  def perform(song_provider_id)
    @provider = SongProvider.find_by(id: song_provider_id, provider_type: :youtube)
    Sidekiq.logger.info('Starting YouTube to audio conversion...')
    return if @provider.nil?

    # Do the split if the file is already attached.
    if @provider.audio_file.present? && @provider.audio_file.source_file.attached?
      SplitfireJob.perform_later(@provider.audio_file.id)
      return
    end

    prepare_environments
    start_processing
  end

  private

  def prepare_environments
    Sidekiq.logger.info('Preparing environments...')
    @youtube_video_id           = @provider.provider_id
    @youtube_video_url          = @provider.preview_url
    @audio_output_file_location = "output/#{@youtube_video_id}.mp3"
  end

  def start_processing
    change_working_directory
    download_and_attach
    split
  end

  def change_working_directory
    Sidekiq.logger.info('Changing working directory...')
    system('echo $PWD')
    Dir.chdir(ENV['YOUTUBE_DL_WORKING_DIRECTORY'])
    broadcast_progress(15)
  end

  def download_and_attach
    Sidekiq.logger.info('Downloading and attaching...')
    video_output_file_format = "output/#{@youtube_video_id}.%(ext)s"
    system("yt-dlp --extract-audio --audio-format mp3 --output \"#{video_output_file_format}\" #{@youtube_video_url}")
    attach
    broadcast_progress(30)
  end

  def attach
    video_title = `yt-dlp --get-title #{@youtube_video_url}`
    audio_output_file = File.open(@audio_output_file_location)

    # Attach audio
    @provider.audio_file.source_file.attach(io: audio_output_file, filename: video_title)
    return unless @provider.audio_file.save

    @provider.audio_file.update(status: :done)
    system("rm #{@audio_output_file_location}")
  end

  def split
    Sidekiq.logger.info('Splitting...')
    @provider.audio_file.update(status: :splitting)
    broadcast_progress(50)
    SplitfireJob.perform_later(@provider.audio_file.id)
  end

  def broadcast_progress(progress)
    @provider.audio_file.update(progress: progress)
    ActionCable.server.broadcast('YoutubeToAudioChannel', @provider.as_json)
  end
end
