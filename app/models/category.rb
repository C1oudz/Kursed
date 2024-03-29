class Category < ApplicationRecord
  after_create :send_telegram_notification
  after_update :send_telegram_notification

  def send_telegram_notification
      Telegram::Bot::Client.run(TOKEN) do |bot|
        bot.api.send_message(chat_id: 569269672, text: "Новая категория: #{self.name}")
      end
  end

    validates :name, presence: true, uniqueness: true
    has_many :posts, dependent: :destroy
    has_many :subscriptions, dependent: :destroy
    has_many :subscribers, through: :subscriptions  
  end
  