# frozen_string_literal: true

class SignedInConstraint
  def matches?(request)
    request.session[:user_id].present?
  end
end

Rails.application.routes.draw do
  resources :articles, param: :uuid
  resources :feed

  get 'about-nameem', to: "static_pages#about_nameem"
  get 'policy', to: "static_pages#policy"

  namespace :api do
    delete 'attachments/delete', to: 'attachments#delete'

    get 'articles/new', to: 'articles#new'
    get 'articles/:uuid/edit', to: 'articles#edit', as: 'articles_edit'

    put 'articles/:uuid/edit', to: 'articles#update', as: 'articles_update'
  end

  ################### Since auth is from scratch ####################
  get 'login', to: 'sessions#new', as: 'login'
  post 'login', to: 'sessions#create'

  get 'signup', to: 'registrations#new', as: 'signup'
  post 'signup', to: 'registrations#create'

  delete 'logout', to: 'sessions#destroy', as: 'logout'

  get "auth/callback", to: "callbacks#new", as: 'callback'
  get "auth/callback/login", to: "callbacks#login", as: 'callback_login'
  post "auth/callback", to: "callbacks#create", as: 'callback_create'

  get 'auth/facebook/callback', to: 'callbacks#facebook'
  get '/auth/failure', to: "home#index"
  ##################################################################

  get 'new-story', to: 'articles#new', as: 'new-story'

  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # When user signed in, we root to the feed
  constraints(SignedInConstraint.new) do
    root "feed#index", as: nil
  end

  root "home#index"
end
