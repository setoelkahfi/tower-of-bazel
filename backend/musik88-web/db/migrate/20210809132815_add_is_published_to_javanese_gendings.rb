class AddIsPublishedToJavaneseGendings < ActiveRecord::Migration[6.0]
  def change
    add_column :javanese_gendings, :is_published, :boolean, default: false
  end
end
