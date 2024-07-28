class ModifyKaraokrFileTable < ActiveRecord::Migration[6.1]
  def change
    remove_reference :karaoke_files, :song, index: true, foreign_key: true
    remove_reference :karaoke_files, :user, index: true, foreign_key: true
    add_reference :karaoke_files, :audio_file, index: true, foreign_key: true
    add_column :karaoke_files, :is_public, :boolean, default: 0
  end
end
