class Post < ApplicationRecord
    # after_create :send_telegram_notification  
    # def send_telegram_notification
    #     subscribers = Subscriber.joins(:user).where(users: { role: ['admin', 'moderator'] }).pluck(:chat_id)
    #     subscribers.each do |chat_id|
    #         Telegram::Bot::Client.run(TOKEN) do |bot|
    #         bot.api.send_message(chat_id: chat_id, text: "Новый пост: #{self.title}")
    #         end
    #     end 
    # end
    belongs_to :category
    validates :category_id, presence: true
    belongs_to :user
    has_many :comments, dependent: :destroy
    validates :title, presence: true, length: {minimum: 5}
    validates :body, presence: true, length: {minimum: 5}   
end