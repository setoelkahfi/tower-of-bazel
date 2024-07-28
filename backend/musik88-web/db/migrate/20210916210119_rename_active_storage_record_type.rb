class RenameActiveStorageRecordType < ActiveRecord::Migration[6.1]
  def self.up
    execute "UPDATE active_storage_attachments a SET record_type = 'AudioFile' FROM active_storage_attachments b WHERE a.id = b.id AND a.record_type = 'SplitAudioFile';"
    execute "UPDATE active_storage_attachments a SET record_type = 'SplitfireResult' FROM active_storage_attachments b WHERE a.id = b.id AND a.record_type = 'SplitAudioFileResult';"
  end
end
