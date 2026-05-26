require "sidekiq/web"
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check


  mount Sidekiq::Web => "/sidekiq"
  root "jobs#index"

  namespace :admin do
    resources :jobs, only: [ :index, :edit, :update, :destroy ]
    root "jobs#index"
  end
  resources :jobs, only: [ :index, :show ]
end
