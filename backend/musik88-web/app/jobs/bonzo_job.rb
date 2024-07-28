class BonzoJob < ApplicationJob
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
      Dir.chdir("/home/deploy/apps/spleeter/")
    else
      Dir.chdir("../spleeter/")
    end

    # Spleet it!
    # Always use the fullpath to the Spleeter.
    # TODO: Tidy up.
    if Rails.env.production?
      system("/home/deploy/.local/bin/spleeter separate -p spleeter:4stems-16kHz -o ./output/ #{file_path} >> spleeter_log.txt")
    else
      system("spleeter separate -p spleeter:4stems-16kHz -o ./output/ #{file_path} >> spleeter_log.txt")
    end
    
    file_output_directory = "output/#{file.source_file.blob.key}"

    # Compose results
    result_bass_path    = "#{file_output_directory}/bass.wav"
    result_vocals_path  = "#{file_output_directory}/vocals.wav"
    result_drums_path   = "#{file_output_directory}/drums.wav"
    result_other_path   = "#{file_output_directory}/other.wav"
    
    # Wait until the resilt files exist...
    until
      File.exist?(result_bass_path) &&
      File.exist?(result_vocals_path) &&
      File.exist?(result_drums_path) &&
      File.exist?(result_other_path)

        system("echo 'We are waiting for the result files...'")
        sleep 5
    end


    # Internal
    # 
    # Save this as VocalFile and BassFile to train a speech recognition AI
    # Only do so if we haven't had it in the database
    unless !VocalFile.find_by(audio_file_id: file.id).nil?
      vocal_file      = File.open(result_vocals_path)
      vocal_filename  = "vocals-#{file.source_file.blob.filename}.wav"
      vocal           = VocalFile.new(audio_file_id: file.id)
  
      vocal.source_file.attach(io: vocal_file, filename: vocal_filename)
      vocal.save
    end

    unless !BassFile.find_by(audio_file_id: file.id).nil?
      bass_file      = File.open(result_bass_path)
      bass_filename  = "bass-#{file.source_file.blob.filename}.wav"
      bass           = BassFile.new(audio_file_id: file.id)
  
      bass.source_file.attach(io: bass_file, filename: bass_filename)
      bass.save
    end

    unless !DrumFile.find_by(audio_file_id: file.id).nil?
      drum_file      = File.open(result_drums_path)
      drum_filename  = "drums-#{file.source_file.blob.filename}.wav"
      drum           = DrumFile.new(audio_file_id: file.id)
  
      drum.source_file.attach(io: drum_file, filename: drum_filename)
      drum.save
    end

    unless !OtherFile.find_by(audio_file_id: file.id).nil?
      other_file      = File.open(result_other_path)
      other_filename  = "other-#{file.source_file.blob.filename}.wav"
      other           = OtherFile.new(audio_file_id: file.id)
  
      other.source_file.attach(io: other_file, filename: other_filename)
      other.save
    end
    #
    # END Internal

    result_drum_backing_track_filename = "drum-backing-track-#{file.source_file.blob.filename}.wav"
    result_drum_backing_track_path = "#{file_output_directory}/#{result_drum_backing_track_filename}"

    system("ffmpeg -i #{result_bass_path} -i #{result_vocals_path} -i #{result_other_path} -filter_complex amix=inputs=3:duration=longest -y '#{result_drum_backing_track_path}'")

    until File.exist?(result_drum_backing_track_path)
      system("echo 'We are waiting for #{result_drum_backing_track_path}...'")
      sleep 60
    end
    result_drum_backing_track_file = File.open(result_drum_backing_track_path)

    # We only save the result if user doesn't cancel the process
    # Ideally, we cancel the running process immediately
    if !file.audio_file_bonzo_status.nil? && file.audio_file_bonzo_status.cancelled?
      system("rm -rf #{file_output_directory}")
      return
    end

    result_drum_backing_track = DrumBackingTrack.new(audio_file_id: file.id)
    result_drum_backing_track.source_file.attach(io: result_drum_backing_track_file, filename: result_drum_backing_track_filename)
    result_drum_backing_track.save
    
      # Cleanup Spleeter output folder
    system("rm -rf #{file_output_directory}")

    if file.audio_file_bonzo_status.nil?
      AudioFileBonzoStatus
        .new(audio_file_id: audio_file_id, status: :done)
        .save
    elsif
      file
        .audio_file_bonzo_status
        .done!
    end

    ActionCable.server.broadcast "BonzoChannel", {
      audio_file_id: file.id,
      message: MyController.render(partial: 'partial_bonzo_row', locals: { audio_file: file} )
    }

  end
end
