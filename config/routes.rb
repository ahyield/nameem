# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    delete 'attachments/delete', to: 'attachments#delete'

    get 'articles/new', to: 'articles#new'
    get 'articles/:uuid/edit', to: 'articles#edit', as: 'articles_edit'

    put 'articles/:uuid/edit', to: 'articles#update', as: 'articles_update'
  end

  resources :articles, param: :uuid

  get 'login', to: 'sessions#new', as: 'login'
  get 'signup', to: 'registrations#new', as: 'signup'
  delete 'logout', to: 'sessions#destroy', as: 'logout'

  get 'new-story', to: 'articles#new', as: 'new-story'

  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'home#index'
end
