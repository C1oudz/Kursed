class CategoriesController < ApplicationController

  def index
    @categories = Category.all
  end

  def show
    @categories=Category.find(params[:id])
    @post = @categories.posts
  end

  def new
      if user_signed_in? && (current_user.moderator? || current_user.admin?)
        @category = Category.new
      else 
        redirect_to home_path, notice: 'Ошибка! Недостаточно прав для этого действия.'
      end
  end

  def edit
    if user_signed_in? && (current_user.moderator? || current_user.admin?)
        @categories=Category.find(params[:id])
    else
        redirect_to home_path, notice: 'Ошибка! Недостаточно прав для этого действия.'
    end
  end

  def create
    @category = Category.new(category_params)
      if user_signed_in? && (current_user.moderator? || current_user.admin?)
        if @category.save
          redirect_to @category
        else
          render 'edit'
        end
      else 
        redirect_to home_path, notice: 'Ошибка! Недостаточно прав для этого действия.'
      end
  end

  def update
    @categories = Category.find(params[:id])
      if user_signed_in? && (current_user.moderator? || current_user.admin?)
        if @categories.update(category_params)
          redirect_to @categories
        else
          render 'edit'
        end
      else 
        redirect_to home_path, notice: 'Ошибка! Недостаточно прав для этого действия.'
      end
  end

    def category_params
      params.require(:category).permit(:name)
    end
end
