class UnmoderatedPostsController < ApplicationController
    def index
        if params[:search]
          @posts = Post.where(status: 0).where("title LIKE ? OR body LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
        else
          @posts = Post.where(status: 0).order(created_at: :desc)
        end
    end
    def show
        @post = Post.find(params[:id])
    end
    def confirm
      if current_user.moderator? || current_user.admin?
        @post = Post.find(params[:id])
        @creator = User.find(@post.user_id)
        puts @creator.chat_id
        if @post.update(status: 1)
          if @creator.chat_id != nil
            Telegram::Bot::Client.run(TOKEN) do |bot|
              # Отправляем сообщение автору о подтверждении его поста
              bot.api.send_message(chat_id: @creator.chat_id, text: "Ваш пост потдвержден модератором: #{@post.title}")
            end 
          end
    
          # Находим категорию поста
          category = @post.category
    
          # Находим подписчиков этой категории
          subscribers = Subscriber.joins(:subscriptions).where(subscriptions: { category_id: category.id }).pluck(:chat_id)
    
          # Отправляем сообщение каждому подписчику категории о новом посте
          subscribers.each do |chat_id|
            Telegram::Bot::Client.run(TOKEN) do |bot|
              bot.api.send_message(chat_id: chat_id, text: "Создан новый пост в категории \"#{category.name}\": #{@post.title}")
            end 
          end
    
          # Отправляем сообщение всем подписчикам о новом посте
          all_subscribers = Subscriber.pluck(:chat_id)
          non_category_subscribers = all_subscribers - subscribers
          non_category_subscribers.each do |chat_id|
            next if chat_id == @creator.chat_id || subscribers.include?(chat_id)
            Telegram::Bot::Client.run(TOKEN) do |bot|
              bot.api.send_message(chat_id: chat_id, text: "Создан новый пост: #{@post.title}")
            end
          end
    
          redirect_to unmoderatedposts_path, notice: 'Пост подтвержден и опубликован.'
        else
          redirect_to request.referrer, alert: 'Не удалось подтвердить пост.'
        end
      else
        redirect_to home_path, alert: 'У вас недостаточно прав.'
      end
    end
    
    def reject
        @post = Post.find(params[:id])
        @creator = User.find(@post.user_id)
        puts @creator.chat_id
        if @post.update(status: 2)
          redirect_to unmoderatedposts_path, notice: 'Пост отклонен.'
          if @creator.chat_id != nil
            Telegram::Bot::Client.run(TOKEN) do |bot|
                bot.api.send_message(chat_id: @creator.chat_id, text: "Ваш пост отклонен модератором по причине не 
                соблюдения правил сообщества: #{@post.title}")
                end 
          end
        else
          redirect_to request.referrer, alert: 'Не удалось отклонить пост.'
        end
      end
    private def post_params
        params.require(:post).permit(:title, :body, :category_id, :current_user_id, status)
    end
end
