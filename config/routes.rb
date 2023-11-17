# frozen_string_literal: true

class SignedInConstraint
  def matches?(request)
    request.session[:user_id].present?
  end
end

class RootNameSpaceRoutes
    TOP_LEVEL_ROUTES = %w[
      -
      .well-known
      404.html
      422.html
      500.html
      502.html
      503.html
      admin
      api
      apple-touch-icon.png
      assets
      dashboard
      articles
      attachments
      settings
      about-nameem
      policy
      explore
      favicon.ico
      favicon.png
      files
      groups
      health_check
      up
      help
      import
      jwt
      login
      oauth
      profile
      projects
      public
      robots.txt
      signup
      search
      sitemap
      sitemap.xml
      sitemap.xml.gz
      uploads
      users
      latest_feed
      popular_feed
      featured_feed
      picked_feed
      user_articles
      feed
      new-story
      auth
      callback
      callback_login
      callback_create
      publish_modal
      static_pages
      home
      sessions
      registrations
      callbacks
      rails
      rails_health_check
      root
    ].freeze

  def matches?(request)
    request.path_parameters[:slug].present? && !TOP_LEVEL_ROUTES.include?(request.path_parameters[:slug])
  end
end

Rails.application.routes.draw do
  resources :articles, param: :uuid
  resources :feed
  resources :users, param: :slug, only: [:show]

  match "settings", to: "users#edit", via: [:get], as: "user_settings"

  scope(path: ':slug', as: :user, constraints: RootNameSpaceRoutes.new, controller: :users) do
    get '/', action: :show

  end


  get "latest_feed", to: "feed#latest_feed", as: "latest_feed"
  get "popular_feed", to: "feed#popular_feed", as: "popular_feed"
  get "featured_feed", to: "feed#featured_feed", as: "featured_feed"
  get "picked_feed", to: "feed#picked_feed", as: "picked_feed"

  get "user_articles/:slug", to: "users#user_articles", as: "user_articles"

  get 'about-nameem', to: "static_pages#about_nameem"
  get 'policy', to: "static_pages#policy"

  get 'publish_modal/:uuid', to: "articles#show_modal", as: "publish_modal"

  namespace :api do
    delete 'attachments/delete', to: 'attachments#delete'

    get 'articles/new', to: 'articles#new'
    get 'articles/:uuid/edit', to: 'articles#edit', as: 'articles_edit'
    get 'articles/:uuid', to: 'articles#show', as: 'show_article'

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
