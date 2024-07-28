class AddLengthAndOnsetToSplitfireResults < ActiveRecord::Migration[6.1]
  def change
    add_column :splitfire_results, :length, :float
    add_column :splitfire_results, :onset, :json
  end
end
