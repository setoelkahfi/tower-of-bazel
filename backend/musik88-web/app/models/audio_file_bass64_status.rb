class AudioFileBass64Status < ApplicationRecord
  belongs_to :split_audio_file, optional: true

  # Enum, enum everywhere...
  enum status: [
      :pending,        # Fresly uploaded file.
      :processing,     # Bass64 processing.
      :done,           # Bass64 done processing file.
      :cancelled,      # Bass64 cancelled processing file.
      :no_results,     # Bass64 The file has been processed before but the result files have been deleted.
  ]
end
