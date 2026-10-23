namespace :backoffice do
  resources :users, param: :slug, only: [:index, :show, :update, :destroy] do
    member do
      post :toggle_role
    end
  end
  resources :articles, param: :uuid, only: [:index, :show, :update, :destroy]
  resources :tags, param: :slug, only: [:index, :show, :update, :destroy] do
    member do
      post :merge
    end
  end
  resources :comments, only: [:index, :show, :destroy]

  get "dashboard", to: "dashboard#index"
  root "dashboard#index"
end
