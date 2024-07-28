class ChangeDefaultvalueForIsPrivate < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :is_private, false
  end
end
