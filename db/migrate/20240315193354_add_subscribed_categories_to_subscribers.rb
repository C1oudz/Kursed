class AddSubscribedCategoriesToSubscribers < ActiveRecord::Migration[6.1]
  def change
    add_column :subscribers, :subscribed_categories, :text
  end
end
