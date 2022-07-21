Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  mount ActionCable.server => "/cable"

  draw :admin
  draw :api

  # BigCommerce App Callbacks URLs
  get "/auth/:provider/callback" => "auth#callback"
  get "/load" => "auth#load"
  get "/uninstall" => "auth#uninstall"

  resources :users, only: [] do
    collection do
      get :me
      post :authorize
    end
  end

  resources :channels, only: [] do
    collection do
      post :connect
      post :settings
      post :requirements
      post :enable
      post :disable
    end
  end

  resources :events, only: :index

  resources :actions, only: [] do
    collection do
      post :sync
      post :cancel
    end
  end

  resources :sync_records, only: [:index, :show] do
    get :sync_operations
  end
end
