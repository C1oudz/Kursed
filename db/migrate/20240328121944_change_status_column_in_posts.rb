class ChangeStatusColumnInPosts < ActiveRecord::Migration[6.1]
  def change
    change_column_default :posts, :status, nil
    change_column :posts, :status, :integer, default: 0
  end
end
