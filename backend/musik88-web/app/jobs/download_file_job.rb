# The SplitFire naming, i.e; camel-cased style, is only being used for branding.
# Inside the code, we refer this tool as Splitfire.

# This meant tobe just a demo job.
class DownloadFileJob < ApplicationJob
  # TODO: Set priority based on account type.
  queue_as :default

  def perform(audio_file_id, public_url)
    require 'open-uri'

    # Change to spleeter working directory.
    if Rails.env.production?
      Dir.chdir('/home/deploy/apps/spleeter/')
    else
      Dir.chdir('../spleeter/')
    end

    download = URI.open(public_url)
    filepath = "#{download.base_uri.to_s.split('/')[-1]}"
    IO.copy_stream(download, filepath)

    file = File.open(filepath)

    audio_file = AudioFile.find_by(id: audio_file_id)
    audio_file.source_file.attach(io: file, filename: filepath)

    return unless audio_file.save

    audio_file.audio_file_splitfire_status.update_attribute(:processing_progress, 10)

    SplitfireDemoJob.perform_later(audio_file.id)

    system("rm -rf #{filepath}")
  end
end
