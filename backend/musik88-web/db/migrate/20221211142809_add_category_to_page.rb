class AddCategoryToPage < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :category, :integer
  end
end
