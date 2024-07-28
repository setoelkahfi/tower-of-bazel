class AudioFileSplitStatus < ApplicationRecord
  belongs_to :audio_file, optional: true

  # Enum, enum everywhere...
  enum status: [
    :youtube_converting,    # Fresly uploaded file.
    :processing,            # Sidekiq is doing its business.
    :done,                  # Done processing file.
    :cancelled,             # Cancelled processing file.
    :no_results            # The file has been processed before but the result files have been deleted.
  ]
end
