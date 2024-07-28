# The KaroKowe naming, i.e; camel-cased style, is only being used for branding.
# Inside the code, we refer this tool as Karokowe.

class KarokoweJob < ApplicationJob
  # TODO: Set priority based on account type.
  queue_as :default

  def perform(audio_file_id)
    # Get the file to split.
    file = AudioFile.find_by(id: audio_file_id)

    # Make sure the actual file is attached.
    # Otherwise, we don't want to do the job.
    return if file.nil? || !file.source_file.attached?

    file_path = ActiveStorage::Blob.service.send(:path_for, file.source_file.key)

    # Change to spleeter working directory.
    # TODO: Tidy up.
    if Rails.env.production?
      Dir.chdir('/home/deploy/apps/spleeter/')
    else
      Dir.chdir('../spleeter/')
    end

    codec = 'mp3'

    # Always use the fullpath to the Spleeter.
    # TODO: Tidy up.
    if Rails.env.production?
      system("/home/deploy/.local/bin/spleeter separate -p spleeter:2stems-16kHz -o ./output/ #{file_path} -c #{codec} >> karokowe_job_log.txt")
    else
      system("spleeter separate -p spleeter:2stems-16kHz -o ./output/ #{file_path} -c #{codec} >> karokowe_job_log.txt")
    end

    file_output_directory = "output/#{file.source_file.blob.key}"

    # Compose results for karaoke
    result_karaoke_path = "#{file_output_directory}/accompaniment.#{codec}"

    # Wait until the file exist...
    until File.exist?(result_karaoke_path)
      system("echo 'We are waiting for #{result_karaoke_path}...'")
      sleep 60
    end

    # We only save the result if user doesn't cancel the process
    # Ideally, we cancel the running process immediately
    if !file.audio_file_karokowe_status.nil? && file.audio_file_karokowe_status.cancelled?
      system("rm -rf #{file_output_directory}")
      return
    end

    result_karaoke_file     = File.open(result_karaoke_path)
    result_karaoke_filename = "karaoke-version-#{file.id}.#{codec}"
    result_karaoke          = KaraokeFile.new(audio_file_id: file.id)

    result_karaoke.source_file.attach(io: result_karaoke_file, filename: result_karaoke_filename)
    result_karaoke.save

    # Cleanup Spleeter output folder
    system("rm -rf #{file_output_directory}")

    if file.audio_file_karokowe_status.nil?
      AudioFileKarokoweStatus.new(audio_file_id: audio_file_id, status: :done).save
    elsif file.audio_file_karokowe_status.done!
    end
  end
end
