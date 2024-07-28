class DrumBackingTrackJob < ApplicationJob
  # TODO: Set priority based on account type.
  queue_as :default
  def perform(audio_file_id)
    # Get the file to split.
    file = AudioFile.find_by(id: audio_file_id)

    # Make sure the actual file is attached.
    # Otherwise, we don't want to do the job.
    return if file.nil? || !file.source_file.attached? || !file.splitfire_results.count.positive?

    # Create the object now
    result_drum_backing_track = DrumBackingTrack.new(audio_file_id: file.id)
    result_drum_backing_track.save

    result_other_path   = ActiveStorage::Blob.service.send(:path_for, file.other_file.source_file.key)
    result_vocals_path  = ActiveStorage::Blob.service.send(:path_for, file.vocals_file.source_file.key)
    result_piano_path   = ActiveStorage::Blob.service.send(:path_for, file.piano_file.source_file.key)
    result_bass_path    = ActiveStorage::Blob.service.send(:path_for, file.bass_file.source_file.key)

    unless result_other_path.present? && result_vocals_path.present? && result_piano_path.present? && result_bass_path.present?
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

    result_drum_backing_track_filename = "drum-backing-track-#{file.id}.#{codec}"

    system("ffmpeg -i #{result_other_path} -i #{result_vocals_path} -i #{result_piano_path} -i #{result_bass_path} -filter_complex amix=inputs=4:duration=longest -y '#{result_drum_backing_track_filename}'")

    status_progress = 10
    until File.exist?(result_drum_backing_track_filename)
      system("echo 'We are waiting for #{result_drum_backing_track_filename}...'")
      result_drum_backing_track.update_attribute(:status_progress, status_progress)
      result_drum_backing_track.save

      status_progress += 1 if status_progress < 100

      sleep 1
    end
    result_drum_backing_track_file = File.open(result_drum_backing_track_filename)
    result_drum_backing_track.source_file.attach(
      io: result_drum_backing_track_file,
      filename: result_drum_backing_track_filename
    )
    result_drum_backing_track.update_attribute(:status, :done)
    result_drum_backing_track.update_attribute(:status_progress, 100)
    result_drum_backing_track.save

    # Cleanup Spleeter output folder
    system("rm #{result_drum_backing_track_filename}")
  end
end
