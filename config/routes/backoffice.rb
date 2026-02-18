namespace :backoffice do
  resources :users, param: :slug
  resources :articles, param: :uuid
  resources :tags, param: :slug do
    member do
      post :merge
    end
  end

  get "dashboard", to: "dashboard#index"
  root "dashboard#index"
end
