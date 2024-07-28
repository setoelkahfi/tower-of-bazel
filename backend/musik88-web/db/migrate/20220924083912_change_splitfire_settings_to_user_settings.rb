class ChangeSplitfireSettingsToUserSettings < ActiveRecord::Migration[6.1]
  def change
    rename_table :splitfire_settings, :user_settings
  end
end
