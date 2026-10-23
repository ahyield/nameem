Rails.application.routes.draw do
  constraints(Constraints::AdminConstraint.new) do
    mount MissionControl::Jobs::Engine, at: "/backoffice/jobs"
  end

  draw :backoffice
  get "search", to: "search#index", as: "search"
  get "search/autocomplete", to: "search#autocomplete", as: "search_autocomplete"
  resources :feed, only: [:index]
  resources :topics, only: %i[index show], param: :slug do
    collection do
      get :search
    end
    member do
      get :articles
      post :follow, to: "follows#create", defaults: { followable_type: "Tag" }
      delete :unfollow, to: "follows#destroy", defaults: { followable_type: "Tag" }
    end
  end
  resources :notifications, only: [:index] do
    member do
      post :mark_read
    end
    collection do
      post :mark_all_read
    end
  end
  scope(path: ":slug", as: :user, constraints: Constraints::RootNamespaceRoutesConstraint.new, controller: :users) do
    get "/", action: :show

    get ":uuid", action: :article, as: "article", constraints: Constraints::ArticleUuidConstraint.new
    delete ":uuid", action: :destroy, as: "destroy_article", constraints: Constraints::ArticleUuidConstraint.new

    post ":uuid/like", action: :create, as: "like_article",
         constraints: Constraints::ArticleUuidConstraint.new, controller: "article_likes"
    delete ":uuid/like", action: :destroy, as: "unlike_article",
           constraints: Constraints::ArticleUuidConstraint.new, controller: "article_likes"

    post ":uuid/bookmark", action: :create, as: "bookmark_article",
         constraints: Constraints::ArticleUuidConstraint.new, controller: "bookmarks"
    delete ":uuid/bookmark", action: :destroy, as: "unbookmark_article",
           constraints: Constraints::ArticleUuidConstraint.new, controller: "bookmarks"

    post ":uuid/comments", action: :create, as: "article_comments",
         constraints: Constraints::ArticleUuidConstraint.new, controller: "comments"
    delete ":uuid/comments/:id", action: :destroy, as: "article_comment",
           constraints: Constraints::ArticleUuidConstraint.new, controller: "comments"

    post ":uuid/comments/:id/like", action: :create, as: "like_comment",
         constraints: Constraints::ArticleUuidConstraint.new, controller: "comment_likes"
    delete ":uuid/comments/:id/like", action: :destroy, as: "unlike_comment",
           constraints: Constraints::ArticleUuidConstraint.new, controller: "comment_likes"
    put ":uuid", to: "articles#update", as: "update_article"
    get ":uuid/edit", to: "articles#edit", as: "edit_article"

    get "publish_modal/:uuid", to: "articles#show_modal", as: "publish_modal"

    post "follow", action: :create, as: "follow", controller: "follows"
    delete "follow", action: :destroy, as: "unfollow", controller: "follows"
    get "followers", action: :followers, as: "followers"
    get "following", action: :following, as: "following"

    get "articles", action: :articles, as: "articles"
    get "drafts", action: :drafts, as: "drafts"
    get "bookmarks", action: :bookmarks, as: "bookmarks"
    get "stats", action: :stats, as: "stats"
  end

  namespace :settings do
    get "profile", to: "profile#edit", as: "user_settings"
    put "profile", to: "profile#update", as: "update_profile"

    get "security", to: "security#edit", as: "security"
    put "security", to: "security#update", as: "update_security"

    get "notifications", to: "notifications#edit", as: "notifications"
    put "notifications", to: "notifications#update", as: "update_notifications"
  end

  get "latest_feed", to: "feed#latest_feed", as: "latest_feed"
  get "picked_feed", to: "feed#picked_feed", as: "picked_feed"
  get "trending_feed", to: "feed#trending_feed", as: "trending_feed"
  get "following_feed", to: "feed#following_feed", as: "following_feed"

  get "about-nameem", to: "static_pages#about_nameem"
  get "terms", to: "static_pages#terms"
  get "privacy", to: "static_pages#privacy"

  namespace :api do
    post "views", to: "views#create"

    post "articles", to: "articles#create"
    get "articles/:slug/:uuid/edit", to: "articles#edit", as: "articles_edit"
    get "articles/:slug/:uuid", to: "articles#show", as: "show_article"

    put "articles/:slug/:uuid", to: "articles#update", as: "articles_update"
  end

  ################### Auth ####################
  get  "login",  to: "sessions#new", as: "login"
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: "logout"

  resource :session, only: [] do
    scope module: :sessions do
      resource :magic_link, only: %i[show create]
    end
  end

  get  "signup", to: "registrations#new", as: "signup"
  post "signup", to: "registrations#create"

  namespace :signups do
    resource :completion, only: %i[new create]
  end
  ################################################

  get "new-story", to: "articles#new", as: "new-story"

  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # When user signed in, we root to the feed
  constraints(Constraints::SignedInConstraint.new) do
    root "feed#index", as: nil
  end

  get "published_articles", to: "home#published_articles", as: "published_articles"
  root "home#index"
end
