class CreateMetaPages < ActiveRecord::Migration[6.0]
  def change
    create_table :meta_pages do |t|
      t.string :home
      t.string :title_en
      t.string :title_id
      t.string :title_sv
      t.text :description_en
      t.text :description_id
      t.text :description_sv

      t.timestamps
    end
  end
end
