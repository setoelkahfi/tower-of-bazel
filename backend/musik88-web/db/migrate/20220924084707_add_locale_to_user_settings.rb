class AddLocaleToUserSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :user_settings, :locale, :integer, default: 0
  end
end
