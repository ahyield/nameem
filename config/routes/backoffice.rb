namespace :backoffice do
  resources :users, param: :slug do
    member do
      post :toggle_role
    end
  end
  resources :articles, param: :uuid
  resources :tags, param: :slug do
    member do
      post :merge
    end
  end
  resources :comments, only: [:index, :show, :destroy]

  get "dashboard", to: "dashboard#index"
  root "dashboard#index"
end
