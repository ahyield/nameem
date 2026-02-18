# frozen_string_literal: true

Rails.application.routes.draw do
  constraints(Constraints::AdminConstraint.new) do
    mount MissionControl::Jobs::Engine, at: "/backoffice/jobs"
  end

  draw :backoffice
  resources :feed, only: [:index]
  scope(path: ':slug', as: :user, constraints: Constraints::RootNamespaceRoutesConstraint.new, controller: :users) do
    get '/', action: :show

    get ":uuid", action: :article, as: "article", constraints: Constraints::ArticleUuidConstraint.new
    delete ":uuid", action: :destroy, as: "destroy_article", constraints: Constraints::ArticleUuidConstraint.new

    post ":uuid/like", action: :create, as: "like_article",
         constraints: Constraints::ArticleUuidConstraint.new, controller: "article_likes"
    delete ":uuid/like", action: :destroy, as: "unlike_article",
           constraints: Constraints::ArticleUuidConstraint.new, controller: "article_likes"

    post ":uuid/comments", action: :create, as: "article_comments",
         constraints: Constraints::ArticleUuidConstraint.new, controller: "comments"
    delete ":uuid/comments/:id", action: :destroy, as: "article_comment",
           constraints: Constraints::ArticleUuidConstraint.new, controller: "comments"
    put ":uuid", to: "articles#update", as: "update_article"
    get ":uuid/edit", to: "articles#edit", as: "edit_article"

    get 'publish_modal/:uuid', to: "articles#show_modal", as: "publish_modal"

    get "articles", action: :articles, as: "articles"
    get "drafts", action: :drafts, as: "drafts"
  end

  namespace :settings do
    get "profile", to: "profile#edit", as: "user_settings"
    put "profile", to: "profile#update", as: "update_profile"

    get "security", to: "security#edit", as: "security"
    put "security", to: "security#update", as: "update_security"
  end

  get "latest_feed", to: "feed#latest_feed", as: "latest_feed"
  get "popular_feed", to: "feed#popular_feed", as: "popular_feed"
  get "picked_feed", to: "feed#picked_feed", as: "picked_feed"

  get 'about-nameem', to: "static_pages#about_nameem"
  get 'terms', to: "static_pages#terms"
  get 'privacy', to: "static_pages#privacy"


  namespace :api do
    delete 'attachments/delete', to: 'attachments#delete'

    get 'articles/new', to: 'articles#new'
    get 'articles/:slug/:uuid/edit', to: 'articles#edit', as: 'articles_edit'
    get 'articles/:slug/:uuid', to: 'articles#show', as: 'show_article'

    put 'articles/:slug/:uuid', to: 'articles#update', as: 'articles_update'
  end

  ################### Auth ####################
  get  'login',  to: 'sessions#new',     as: 'login'
  post 'login',  to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy', as: 'logout'

  resource :session, only: [] do
    scope module: :sessions do
      resource :magic_link, only: [:show, :create]
    end
  end

  get  'signup', to: 'registrations#new',    as: 'signup'
  post 'signup', to: 'registrations#create'

  namespace :signups do
    resource :completion, only: [:new, :create]
  end
  ################################################

  get 'new-story', to: 'articles#new', as: 'new-story'

  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # When user signed in, we root to the feed
  constraints(Constraints::SignedInConstraint.new) do
    root "feed#index", as: nil
  end

  get "published_articles", to: "home#published_articles", as: "published_articles"
  root "home#index"
end
