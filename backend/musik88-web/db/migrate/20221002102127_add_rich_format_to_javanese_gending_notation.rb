class AddRichFormatToJavaneseGendingNotation < ActiveRecord::Migration[6.1]
  def change
    add_column :javanese_gending_notations, :rich_format, :json
  end
end
