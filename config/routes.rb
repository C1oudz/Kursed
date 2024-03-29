Rails.application.routes.draw do
  get 'verification_codes/new'
  get 'verification_codes/create'
  devise_for :users, controllers: { registrations: 'users/registrations' }
  devise_for :views
root'posts#index', as: 'home'

get 'laba1' => 'pages#laba1', as: 'laba1'
get 'about' => 'pages#about', as: 'about'
get 'my' => 'posts#my', as: 'my'
get 'category' => 'categories#index', as: 'cat'
get 'newcategory' => 'categories#new', as: 'newcat'
get 'allusers' => 'users#index', as: 'allusers'   
get 'unmoderatedposts' => 'unmoderated_posts#index', as: 'unmoderatedposts'
get 'moderatepost' => 'unmoderated_posts#show', as: 'moderatepost'
patch 'confirm' => 'unmoderated_posts#confirm', as: 'confirmpost'
patch 'reject' => 'unmoderated_posts#reject', as: 'rejectpost'
resources :posts do 
    resources :comments
end
resources :verification_codes, only: [:new, :create]
patch 'resetchaid' => 'verification_codes#resetchatid', as: 'resetchatid'
resources :users
get 'change_roles/:id/user', to: 'users#change_roles', as: 'change_roles'

get 'user_posts/:user_id' => 'posts#user', as: :user_posts
resources :categories


end
