# frozen_string_literal: true

class AudioAnalysisJob < ApplicationJob
  queue_as :default

  def perform(audio_file_id)
    # Get the file to split.
    @file = AudioFile.find_by(id: audio_file_id)

    # Return early if the file is not found.
    return if @file.nil?

    # Perform result files processing.
    bass = @file.bass_file
    AudioAnalysisSplitfireResultJob.perform_later(bass.id)
    vocal = @file.vocals_file
    AudioAnalysisSplitfireResultJob.perform_later(vocal.id)
    drum = @file.drums_file
    AudioAnalysisSplitfireResultJob.perform_later(drum.id)
    other = @file.other_file
    AudioAnalysisSplitfireResultJob.perform_later(other.id)
  end
end
