class CreateSplitfireSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :splitfire_settings do |t|
      t.references :user, foreign_key: true
      t.integer :model
      t.integer :frequency

      t.timestamps
    end
  end
end
