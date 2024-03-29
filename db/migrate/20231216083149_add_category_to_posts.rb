class AddCategoryToPosts < ActiveRecord::Migration[6.1]
  def change
    default_category = Category.create!(name: 'Uncategorized')
    add_reference :posts, :category, null: false, foreign_key: true, default: default_category.id
    change_column_default :posts, :category_id, nil
  end
end
