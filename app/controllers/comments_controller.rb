class CommentsController < ApplicationController
    def create
        @post = Post.find(params[:post_id])
        @comment = @post.comments.create(comment_params.merge(user_id: current_user.id))
        @creator = User.find(@post.user_id)
        puts @creator.chat_id
        if current_user != @creator
        Telegram::Bot::Client.run(TOKEN) do |bot|
            bot.api.send_message(chat_id: @creator.chat_id, text: "Ваш пост: #{@post.title} прокомментировали: #{@comment.body}")
            end 
        end
        redirect_to post_path(@post)
    end

    def destroy
        @post = Post.find(params[:post_id])
        @comment = @post.comments.find(params[:id])
        if user_signed_in? && (current_user == @comment.user) 
            @comment.destroy
            redirect_to post_path(@post), notice: 'Комментарий успешно удален.'
        else
        redirect_to post_path(@post), notice: 'Вы не можете удалить чужой комментарий.'
        end
    end

    def edit
        @post = Post.find(params[:post_id])
        @comment = @post.comments.find(params[:id])
       if user_signed_in? && (current_user == @comment.user) 
            else
            redirect_to post_path(@post), notice: 'Вы не можете редактировать чужой комментарий.'
        end
    end

   
   def update
    @post = Post.find(params[:post_id])
        @comment = @post.comments.find(params[:id])
        if user_signed_in? && (current_user == @comment.user) 
            if @comment.update(comment_params)
            redirect_to post_path(@post), notice: 'Комментарий успешно обновлен.'
            else
            render :edit
            end
        else
            redirect_to post_path(@post), notice: 'Вы не можете редактировать чужой комментарий.'
        end
    end

    private def comment_params
        params.require(:comment).permit(:firstname, :body, :user_id)
    end
end
