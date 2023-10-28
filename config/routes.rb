Rails.application.routes.draw do
  namespace :api do
    delete 'attachments/delete', to: "attachments#delete"
  end
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
