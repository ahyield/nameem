namespace :backoffice do
  resources :users, param: :slug
  resources :articles, param: :uuid

  get "dashboard", to: "dashboard#index"
  root "dashboard#index"
end
