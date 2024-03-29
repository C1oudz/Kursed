require 'telegram/bot'

TOKEN = '7014059496:AAFWZWkLWKHWZ3jnIRO6qKgFgTYm3qMg5cE'

# Метод для отправки сообщения в чат
def send_message(chat_id, text)
  # Ваш код для отправки сообщения в телеграм
end

Thread.new do
  Telegram::Bot::Client.run(TOKEN) do |bot|
    bot.listen do |message|
      case message
      when Telegram::Bot::Types::Message
        chat_id = message.chat.id
        case message.text
        when '/start'
          chatid_user = Subscriber.find_by(chat_id: chat_id)
          if chatid_user.present?
            puts "User with chat_id #{chat_id} already exists"
            bot.api.send_message(chat_id: chat_id, text: "Вы уже подписались на бота")
          else
            puts "User with chat_id #{chat_id} does not exist, creating new user"
            Subscriber.create(chat_id: chat_id)
            bot.api.send_message(chat_id: chat_id, text: "Вы подписались на оповещения. Список команд: /help")
          end
        when '/help'
          bot.api.send_message(chat_id: chat_id, text: "Список команд:\n/login - привязать телеграм к аккаунту на сайте.\n/categories - вывести список категорий.\n/delcat - отписаться от категорий.\n/stop - отписаться от оповещений.
          ")
        when '/login'
          # Генерируем случайный код на 5 минут
          code = rand(100_000..999_999)
          # Сохраняем код и chat_id пользователя в базе данных
          VerificationCode.create(chat_id: chat_id, code: code, expires_at: Time.now + 5.minutes)
          # Отправляем код пользователю
          bot.api.send_message(chat_id: chat_id, text: "Код для привязки аккаунта: #{code}")
        when '/stop'
          Subscriber.find_by(chat_id: chat_id)&.destroy
          bot.api.send_message(chat_id: chat_id, text: "Вы отписались от оповещений.")
        when '/categories'
          # Извлекаем все категории из базы данных
          all_categories = Category.all
          
          # Находим подписанные категории пользователя
          subscribed_categories = Subscriber.find_by(chat_id: chat_id)&.subscribed_categories
          
          # Определяем категории, на которые пользователь еще не подписан
          categories_to_show = all_categories - subscribed_categories
          
          # Формируем массив кнопок для каждой категории
          buttons = categories_to_show.map do |category|
            [Telegram::Bot::Types::InlineKeyboardButton.new(text: category.name, callback_data: "subscribe_#{category.id}")]
          end
          
          # Формируем разметку клавиатуры с кнопками категорий
          markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
          
          # Отправляем пользователю сообщение с клавиатурой категорий
          bot.api.send_message(chat_id: chat_id, text: 'Выберите категорию на которую хотите подписаться:', reply_markup: markup)  
        when '/delcat'
          # Получаем пользователя, который отправил команду
          subscriber = Subscriber.find_by(chat_id: message.from.id)
          if subscriber.present? && subscriber.subscribed_categories.present?
            # Получаем список категорий, на которые подписан пользователь
            subscribed_categories = subscriber.subscribed_categories
            
            # Формируем массив кнопок для каждой категории
            buttons = subscribed_categories.map do |category|
              [Telegram::Bot::Types::InlineKeyboardButton.new(text: category.name, callback_data: "unsubscribe_#{category.id}")]
            end
            
            # Формируем разметку клавиатуры с кнопками категорий
            markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
            
            # Отправляем пользователю сообщение с клавиатурой категорий для отписки
            bot.api.send_message(chat_id: chat_id, text: 'Выберите категорию, от которой хотите отписаться:', reply_markup: markup)
          else
            # Если пользователя не найден или он не подписан ни на одну категорию, отправляем соответствующее сообщение
            bot.api.send_message(chat_id: chat_id, text: 'Вы не подписаны ни на одну категорию.')
          end
        else
          bot.api.send_message(chat_id: chat_id, text: "Неизвестная команда")
        end
      when Telegram::Bot::Types::CallbackQuery
        if message.data.start_with?('subscribe_')
          # Получаем id категории из callback_data
          category_id = message.data.sub('subscribe_', '').to_i
          # Находим категорию по id
          category = Category.find(category_id)
           # Находим подписчика по chat_id
          subscriber = Subscriber.find_by(chat_id: message.from.id)
          # Формируем сообщение для отправки
          if subscriber
            # Создаем подписку для данного подписчика на указанную категорию
            subscription = Subscription.find_or_create_by(subscriber_id: subscriber.id, category_id: category.id)

            response_text = "Вы подписались на категорию #{category.name}"
          else
            response_text = "Произошла ошибка. Пожалуйста, попробуйте снова."
          end
          
          # Отправляем сообщение пользователю
          bot.api.send_message(chat_id: message.from.id, text: response_text)    
        end
        if message.data.start_with?('unsubscribe_')
          # Получаем id категории из callback_data
          category_id = message.data.sub('unsubscribe_', '').to_i
          # Находим категорию по id
          category = Category.find(category_id)
          # Находим подписчика по chat_id
          subscriber = Subscriber.find_by(chat_id: message.from.id)
          # Если подписчик и категория найдены, отписываем его от категории
          if subscriber && category
            # Находим подписку по subscriber_id и category_id и удаляем её
            subscription = Subscription.find_by(subscriber_id: subscriber.id, category_id: category.id)
            subscription.destroy if subscription.present?
            bot.api.send_message(chat_id: message.from.id, text: "Вы успешно отписались от категории #{category.name}")
          else
            bot.api.send_message(chat_id: message.from.id, text: "Произошла ошибка при отписке от категории.")
          end
        end
      end
    end
  end
end

