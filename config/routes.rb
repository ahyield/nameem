# frozen_string_literal: true

Rails.application.routes.draw do
  resources :feed

  scope(path: ':slug', as: :user, constraints: Constraints::RootNamespaceRoutesConstraint.new, controller: :users) do
    get '/', action: :show
    get ":uuid", action: :article, as: "article", constraints: Constraints::ArticleUuidConstraint.new

    put ":uuid", to: "articles#update", as: "update_article"

    get ":uuid/edit", to: "articles#edit", as: "edit_article"

    get 'publish_modal/:uuid', to: "articles#show_modal", as: "publish_modal"
    get "articles", action: :articles, as: "articles"

  end

  match "settings", to: "users#edit", via: [:get], as: "user_settings"

  get "latest_feed", to: "feed#latest_feed", as: "latest_feed"
  get "popular_feed", to: "feed#popular_feed", as: "popular_feed"
  get "featured_feed", to: "feed#featured_feed", as: "featured_feed"
  get "picked_feed", to: "feed#picked_feed", as: "picked_feed"

  get 'about-nameem', to: "static_pages#about_nameem"
  get 'policy', to: "static_pages#policy"


  namespace :api do
    delete 'attachments/delete', to: 'attachments#delete'

    get 'articles/new', to: 'articles#new'
    get ':slug/:uuid/edit', to: 'articles#edit', as: 'articles_edit'
    get ':slug/:uuid', to: 'articles#show', as: 'show_article'

    put ':slug/:uuid/edit', to: 'articles#update', as: 'articles_update'
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
  constraints(Constraints::SignedInConstraint.new) do
    root "feed#index", as: nil
  end

  root "home#index"
end
