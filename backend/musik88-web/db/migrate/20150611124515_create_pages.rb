class CreatePages < ActiveRecord::Migration[5.2]
  def change
    create_table :pages do |t|
      t.string :page_slug
      t.text :page_content
      t.string :locale

      t.timestamps
    end
  end
end
