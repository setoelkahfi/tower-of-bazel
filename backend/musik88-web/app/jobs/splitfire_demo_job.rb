# The SplitFire naming, i.e; camel-cased style, is only being used for branding.
# Inside the code, we refer this tool as Splitfire.

# This meant tobe just a demo job.
class SplitfireDemoJob < ApplicationJob
  # TODO: Set priority based on account type.
  queue_as :default

  def perform(audio_file_id)
    # Get the file to split.
    @file = AudioFile.find_by(id: audio_file_id)

    # Make sure the actual file is attached.
    # Otherwise, we don't want to do the job.
    return if @file.nil? || !@file.source_file.attached?

    file_path = ActiveStorage::Blob.service.send(:path_for, @file.source_file.key)

    broadcast_progress(20)

    # Change to spleeter working directory.
    if Rails.env.production?
      Dir.chdir('/home/deploy/apps/spleeter/')
    else
      Dir.chdir('../spleeter/')
    end

    # Compute the params.
    splitfire_setting = UserSetting.find_by(user_id: 69) # Always use @splitfire setting.
    spleeter_param    = splitfire_setting.model.to_s
    spleeter_param    = "#{spleeter_param}-#{splitfire_setting.frequency}" if splitfire_setting.frequency == '16kHz'
    @codec            = 'mp3'

    broadcast_progress(30)

    # Spleet it! Always use the fullpath to the Spleeter.
    if Rails.env.production?
      system("/home/deploy/.local/bin/spleeter separate -p spleeter:#{spleeter_param} -o ./output/ #{file_path} -c #{@codec} >> spleeter_log.txt")
    else
      system("spleeter separate -p spleeter:#{spleeter_param} -o ./output/ #{file_path} -c #{@codec} >> spleeter_log.txt")
    end

    broadcast_progress(50)

    @file_output_directory = "output/#{@file.source_file.blob.key}"

    # Start from the beginning.
    SplitfireResult
      .where(audio_file_id: @file.id)
      .destroy_all

    compose_result_vocals
    compose_result_bass
    compose_result_drums
    compose_result_other
    compose_result_piano

    broadcast_progress(90)

    # Cleanup Spleeter output folder
    system("rm -rf #{@file_output_directory}")

    @file.audio_file_splitfire_status.done!

    broadcast_progress(100)
  end

  private

  def compose_result_vocals
    result_vocals_path = "#{@file_output_directory}/vocals.#{@codec}"

    waiting_console(result_vocals_path)

    result_vocals_file      = File.open(result_vocals_path)
    result_vocals_filename  = "vocals-#{@file.id}.#{@codec}"
    result_vocals           = SplitfireResult.new(audio_file_id: @file.id)

    result_vocals.source_file.attach(io: result_vocals_file, filename: result_vocals_filename)
    result_vocals.save
  end

  def compose_result_drums
    result_drums_path = "#{@file_output_directory}/drums.#{@codec}"

    waiting_console(result_drums_path)

    result_drums_file     = File.open(result_drums_path)
    result_drums_filename = "drums-#{@file.id}.#{@codec}"
    result_drums          = SplitfireResult.new(audio_file_id: @file.id)

    result_drums.source_file.attach(io: result_drums_file, filename: result_drums_filename)
    result_drums.save
  end

  def compose_result_bass
    result_bass_path = "#{@file_output_directory}/bass.#{@codec}"

    waiting_console(result_bass_path)

    result_bass_file     = File.open(result_bass_path)
    result_bass_filename = "bass-#{@file.id}.#{@codec}"
    result_bass          = SplitfireResult.new(audio_file_id: @file.id)

    result_bass.source_file.attach(io: result_bass_file, filename: result_bass_filename)
    result_bass.save
  end

  def compose_result_other
    result_other_path = "#{@file_output_directory}/other.#{@codec}"

    waiting_console(result_other_path)

    result_other_file     = File.open(result_other_path)
    result_other_filename = "other-#{@file.id}.#{@codec}"
    result_other          = SplitfireResult.new(audio_file_id: @file.id)

    result_other.source_file.attach(io: result_other_file, filename: result_other_filename)
    result_other.save
  end

  def compose_result_piano
    result_piano_path = "#{@file_output_directory}/piano.#{@codec}"

    waiting_console(result_piano_path)

    result_piano_file     = File.open(result_piano_path)
    result_piano_filename = "piano-#{@file.id}.#{@codec}"
    result_piano          = SplitfireResult.new(audio_file_id: @file.id)

    result_piano.source_file.attach(io: result_piano_file, filename: result_piano_filename)
    result_piano.save
  end

  def waiting_console(file_path)
    until File.exist?(file_path)
      system("echo 'We are waiting for #{file_path}...'")
      sleep 60
    end
  end

  def broadcast_progress(progress)
    @file.audio_file_splitfire_status.update_attribute(:processing_progress, progress)
    ActionCable.server.broadcast('FileProcessingChannel', @file.as_json_packed)
  end
end
