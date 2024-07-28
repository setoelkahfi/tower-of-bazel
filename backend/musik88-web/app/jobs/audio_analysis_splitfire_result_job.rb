# frozen_string_literal: true

class AudioAnalysisSplitfireResultJob < ApplicationJob
  queue_as :default

  def perform(splitfire_result_id)
    # Get the file to split.
    @file = SplitfireResult.find_by(id: splitfire_result_id)

    # Make sure the actual file is attached.
    # Otherwise, we don't want to do the job.
    return if @file.nil? || !@file.source_file.attached?

    Sidekiq.logger.debug("File: #{@file}")

    # Change working directory to the output folder.
    change_working_directory

    length_and_onset do |length, onset|
      @file.update(length: length, onset: onset)
      Sidekiq.logger.debug("Length: #{length}, Onset: #{onset}")
    end
  end

  private

  def length_and_onset
    Sidekiq.logger.info('Starting AudioAnalysisJob processing...')
    @file.source_file.open do |file|
      Sidekiq.logger.debug("File path: #{file.path}")
      result = `python audio_length.py #{file.path}`
      onset = `python onset.py #{file.path}`
      # Process onset string into array.
      onset = onset_string_to_array(onset)
      yield(result, onset)
    end
  end

  def onset_string_to_array(onset)
    onset.delete('[]').split.map(&:to_f)
  end

  def change_working_directory
    Sidekiq.logger.info('Changing working directory...')
    Dir.chdir(ENV['AUDIO_ANALYSIS_WORKING_DIRECTORY'])
    system('echo $PWD')
  end
end
