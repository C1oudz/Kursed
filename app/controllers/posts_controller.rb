class PostsController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show]
    def index
        if params[:search]
          @posts = Post.where(status: 1).where("title LIKE ? OR body LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
        else
          @posts = Post.where(status: 1).order(updated_at: :desc)
        end
    end
    
    def user
      @user = User.find( params[:user_id] )
      if current_user == @user || current_user.admin? || current_user.moderator?
      @posts = Post.where( user: @user ).order( created_at: :desc )
      else
        @posts = Post.where( user: @user ).where( status: 1 ).order( created_at: :desc )
      end
    end

    def my
      @posts = current_user.posts.order(created_at: :desc)
    end

    def new
        @post = Post.new
        @categories=Category.all.order(:name)
    end

    def show
        @post = Post.find(params[:id])
    end

    def edit
        @post = Post.find(params[:id])
        @category=Category.all.order(:name)
        unless current_user == @post.user
            redirect_to posts_path, alert: 'Вы можете редактировать только свои посты'
        end
    end

    def update
        @post = Post.find(params[:id])

        if current_user == @post.user && current_user.user?
          @post.status = 0
          if @post.update(post_params)
            redirect_to @post, notice: 'Пост успешно обновлен и отправален на модерцию'
            admins = User.where(role: ['admin', 'moderator']).where.not(chat_id: nil)
            admins.each do |admin|
              Telegram::Bot::Client.run(TOKEN) do |bot|
                bot.api.send_message(chat_id: admin.chat_id, text: "Обновленный пост на модерации: #{@post.title}")
              end
            end 
          else
            @categories=Category.all.order(:name)
            render :edit, categories: @categories
          end
        elsif current_user == @post.user && (current_user.admin? || current_user.moderator?)
              @post.status = 1
              if @post.update(post_params)
                redirect_to @post, notice: 'Пост успешно обновлен'
                subscribers = Subscriber.pluck(:chat_id)
                subscribers.each do |chat_id|
                  Telegram::Bot::Client.run(TOKEN) do |bot|
                      bot.api.send_message(chat_id: chat_id, text: "Обновлен пост: #{@post.title}")
                      end 
                end
            else
              @categories=Category.all.order(:name)
              render :edit, categories: @categories
            end
        else
          redirect_to posts_path, alert: 'Вы можете редактировать только свои посты'
        end
    end

    def destroy
        @post = Post.find(params[:id])
        @creator = User.find(@post.user_id)
        puts @creator.chat_id
        if current_user == @post.user || current_user.moderator? || current_user.admin?
          @post.destroy
          redirect_to posts_path, notice: 'Пост успешно удален'
          if @creator.chat_id != nil
            Telegram::Bot::Client.run(TOKEN) do |bot|
              # Отправляем сообщение автору о подтверждении его поста
              bot.api.send_message(chat_id: @creator.chat_id, text: "Ваш пост был удален: #{@post.title}")
            end 
          end
        else
          redirect_to posts_path, alert: 'Вы не можете удалить этот пост'
        end
    end

    def create
      @post = current_user.posts.build(post_params)
      
      if current_user.admin? || current_user.moderator?
        @post.status = 1
        
        if @post.save
          subscribers = Subscriber.joins(:subscriptions).where(subscriptions: { category_id: @post.category_id }).pluck(:chat_id)
          subscribers.each do |chat_id|
            Telegram::Bot::Client.run(TOKEN) do |bot|
              bot.api.send_message(chat_id: chat_id, text: "Новый пост в категории \"#{Category.find(@post.category_id).name}\": #{@post.title}")
            end
          end
          all_subscribers = Subscriber.pluck(:chat_id)
          non_category_subscribers = all_subscribers - subscribers
          non_category_subscribers.each do |chat_id|
            Telegram::Bot::Client.run(TOKEN) do |bot|
              bot.api.send_message(chat_id: chat_id, text: "Создан новый пост: #{@post.title}")
            end
          end
          redirect_to home_path, notice: 'Пост подтвержден и опубликован.'
        else
          @categories = Category.all.order(:name)
          render 'new', categories: @categories
        end
      else
        if @post.save
          admins = User.where(role: ['admin', 'moderator']).where.not(chat_id: nil)
      
          admins.each do |admin|
            Telegram::Bot::Client.run(TOKEN) do |bot|
              bot.api.send_message(chat_id: admin.chat_id, text: "Новый пост на модерации: #{@post.title}")
            end
          end 
          redirect_to home_path, notice: 'Пост отправлен на модерацию'
        else
          @categories = Category.all.order(:name)
          render 'new', categories: @categories
        end
      end
    end

    private def post_params
        params.require(:post).permit(:title, :body, :category_id, :current_user_id)
    end
end
