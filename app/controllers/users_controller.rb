class UsersController < ApplicationController
    def index
        @users = User.all.order(created_at: :desc)
    end

    def change_roles
        if current_user.admin? 
          @user = User.find(params[:id]) # Найти пользователя по его id
        else
            redirect_to posts_path, alert: 'Вы не имеете доступа'
        end
    end

    def update
        if current_user.admin? 
          @user = User.find(params[:id])
          if @user.update(user_params)
             redirect_to allusers_path, notice: 'Роль была успешно изменена.'
          else
             render :change_roles
          end
        end
    end

    def user_params
        params.require(:user).permit(:firstnamename, :email, :password, :password_confirmation, :role)
    end
end
