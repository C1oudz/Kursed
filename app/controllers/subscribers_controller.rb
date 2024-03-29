class SubscribersController < ApplicationController
    def subscribe
        chat_id = params[:chat_id] # Предположим, что chat_id приходит через параметры запроса
        Subscriber.create(chat_id: chat_id)
        # Другие действия, которые вы хотите выполнить при подписке пользователя
    end
    
end
