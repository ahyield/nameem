Rails.application.routes.draw do
  namespace :api do
    delete 'attachments/delete', to: "attachments#delete"

    get "articles/new", to: "articles#new"
    put "articles/:uuid/edit", to: "articles#edit"
  end
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources "articles", param: :uuid

  get "new_article", to: "articles#new", as: "create_article"

  root "home#index"
end
