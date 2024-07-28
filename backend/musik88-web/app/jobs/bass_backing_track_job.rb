class BassBackingTrackJob < ApplicationJob
  # TODO: Set priority based on account type.
  queue_as :default
  def perform(audio_file_id)
    # Get the file to split.
    file = AudioFile.find_by(id: audio_file_id)

    # Make sure the actual file is attached.
    # Otherwise, we don't want to do the job.
    return if file.nil? || !file.source_file.attached? || !file.splitfire_results.count.positive?

    # Create the object now
    result_bass_backing_track = BassBackingTrackFile.new(audio_file_id: file.id)
    result_bass_backing_track.save

    result_drums_path   = ActiveStorage::Blob.service.send(:path_for, file.drums_file.source_file.key)
    result_vocals_path  = ActiveStorage::Blob.service.send(:path_for, file.vocals_file.source_file.key)
    result_piano_path   = ActiveStorage::Blob.service.send(:path_for, file.piano_file.source_file.key)
    result_other_path = ActiveStorage::Blob.service.send(:path_for, file.other_file.source_file.key)

    unless result_drums_path.present? && result_vocals_path.present? && result_piano_path.present? && result_other_path.present?
      return
    end

    # Prepare working directory.
    working_directory_path = if Rails.env.production?
                               '/home/deploy/apps/ffmpeg/'
                             else
                               '../ffmpeg/'
                             end

    Dir.chdir(working_directory_path)

    codec = 'mp3'

    file_output_directory = file.source_file.blob.key.to_s

    result_bass_backing_track_filename = "bass-backing-track-#{file.id}.#{codec}"

    system("ffmpeg -i #{result_drums_path} -i #{result_vocals_path} -i #{result_piano_path} -i #{result_other_path} -filter_complex amix=inputs=4:duration=longest -y '#{result_bass_backing_track_filename}'")

    status_progress = 10
    until File.exist?(result_bass_backing_track_filename)
      system("echo 'We are waiting for #{result_bass_backing_track_filename}...'")
      result_bass_backing_track.update_attribute(:status_progress, status_progress)
      result_bass_backing_track.save

      status_progress += 1 if status_progress < 100

      sleep 1
    end
    result_bass_backing_track_file = File.open(result_bass_backing_track_filename)
    result_bass_backing_track.source_file.attach(
      io: result_bass_backing_track_file,
      filename: result_bass_backing_track_filename
    )
    result_bass_backing_track.update_attribute(:status, :done)
    result_bass_backing_track.update_attribute(:status_progress, 100)
    result_bass_backing_track.save

    # Cleanup Spleeter output folder
    system("rm #{result_bass_backing_track_filename}")
  end
end
