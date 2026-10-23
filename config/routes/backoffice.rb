namespace :backoffice do
  resources :users, param: :slug, only: %i[index show update destroy] do
    member do
      post :toggle_role
      post :suspend
      post :unsuspend
      post :unsuppress_email
    end
  end
  resources :articles, param: :uuid, only: %i[index show update destroy]
  resources :tags, param: :slug, only: %i[index show update destroy] do
    member do
      post :merge
    end
  end
  resources :comments, only: %i[index show destroy]
  resources :reports, only: %i[index show] do
    member do
      post :resolve
    end
  end

  get "dashboard", to: "dashboard#index"
  root "dashboard#index"
end
