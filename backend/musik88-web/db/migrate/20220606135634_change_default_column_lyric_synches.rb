class ChangeDefaultColumnLyricSynches < ActiveRecord::Migration[6.1]
  def change
    change_column :lyric_synches, :created_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    change_column :lyric_synches, :updated_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
