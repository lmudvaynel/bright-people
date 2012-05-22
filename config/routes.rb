BrightPeople::Application.routes.draw do
  get "organizations/show"

  ActiveAdmin.routes(self)

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  put 'users/email' => 'users#update_email', as: :update_user_email
  devise_for :admin_users, ActiveAdmin::Devise.config

  resources :organizations, :only => [:show]
  resources :activities, :only => [:index, :show]
  resources :experts, :only => [:index, :show]

  root :to => 'home#show'
end
