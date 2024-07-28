# The SplitFire naming, i.e; camel-cased style, is only being used for branding.
# Inside the code, we refer this tool as Splitfire.

class SplitfireJob < ApplicationJob
  queue_as :default

  def perform(audio_file_id)
    # Get the file to split.
    @file = AudioFile.find_by(id: audio_file_id)

    # Make sure the actual file is attached.
    # Otherwise, we don't want to do the job.
    return if @file.nil? || !@file.source_file.attached?

    # Change working directory to the Spleeter output folder.
    change_working_directory
    process_split_file do |path|
      process_results(path) if path.present?
    end
  end

  private

  def process_results(path)
    Sidekiq.logger.info("Processing results in #{path} ...")
    @file_output_directory = path
    # Process results
    process_vocals_file
    process_drums_file
    process_bass_file
    process_other_file

    Sidekiq.logger.info('Finishing process ...')
    system("rm -rf #{@file_output_directory}")
    @file.update(progress: 100)
    @file.done!
  end

  def change_working_directory
    Sidekiq.logger.info('Changing working directory...')
    Dir.chdir(ENV['AUDIO_WORKING_DIRECTORY'])
    system('echo $PWD')
  end

  def process_split_file
    Sidekiq.logger.info('Starting Splitfire processing...')

    @file.source_file.open do |file|
      system("echo 'File path: #{file.path}'")
      system("python3 -m demucs -n=htdemucs_ft -d cpu #{file.path} >> demucs_log.txt")
      # get filename from path
      filename = file.path.split('/').last
      # If filename consist of dot, split it and get the first part
      filename = filename.split('.').first if filename.include?('.')
      file_output_directory = "separated/htdemucs_ft/#{filename}"
      yield(file_output_directory)
    end
  end

  def process_vocals_file
    Sidekiq.logger.info('Processing vocals file...')
    # Compose results for vocals
    result_vocals_path      = "#{@file_output_directory}/vocals.wav"
    result_vocals_file      = File.open(result_vocals_path)
    result_vocals_filename  = "vocals-#{@file.source_file.blob.filename}.wav"
    vocal                   = SplitfireResult.new(audio_file_id: @file.id)
    vocal.source_file.attach(io: result_vocals_file, filename: result_vocals_filename)
    vocal.save
    save_vocals_file(result_vocals_file, result_vocals_filename)
  end

  def save_vocals_file(result_vocals_path, result_vocals_filename)
    Sidekiq.logger.info('Saving vocals file...')
    result_vocals_file = File.open(result_vocals_path)
    vocal = VocalFile.new(audio_file_id: @file.id)
    vocal.source_file.attach(io: result_vocals_file, filename: result_vocals_filename)
    vocal.save
  end

  def process_drums_file
    Sidekiq.logger.info('Processing drums file...')
    # DRUMS
    result_drums_path = "#{@file_output_directory}/drums.wav"
    result_drums_file     = File.open(result_drums_path)
    result_drums_filename = "drums-#{@file.source_file.blob.filename}.wav"
    result_drums          = SplitfireResult.new(audio_file_id: @file.id)
    result_drums.source_file.attach(io: result_drums_file, filename: result_drums_filename)
    result_drums.save
  end

  def process_bass_file
    Sidekiq.logger.info('Processing bass file...')
    # BASS
    result_bass_path = "#{@file_output_directory}/bass.wav"
    result_bass_file     = File.open(result_bass_path)
    result_bass_filename = "bass-#{@file.source_file.blob.filename}.wav"
    result_bass          = SplitfireResult.new(audio_file_id: @file.id)
    result_bass.source_file.attach(io: result_bass_file, filename: result_bass_filename)
    result_bass.save
  end

  def process_other_file
    Sidekiq.logger.info('Processing other file...')
    # OTHER
    result_other_path = "#{@file_output_directory}/other.wav"
    result_other_file     = File.open(result_other_path)
    result_other_filename = "other-#{@file.source_file.blob.filename}.wav"
    result_other          = SplitfireResult.new(audio_file_id: @file.id)
    result_other.source_file.attach(io: result_other_file, filename: result_other_filename)
    result_other.save
  end

  def broadcast_progress(progress)
    @file.audio_file_split_status.update_attribute(:processing_progress, progress)

    ActionCable.server.broadcast 'SplitfireChannel', {
      audio_file_id: @file.id,
      partial_splitfire_row: MyController.render(partial: 'partial_splitfire_row', locals: { audio_file: @file })
    }
  end
end
