# frozen_string_literal: true

namespace :api do
  namespace :v1 do
    scope ":store_hash" do
      resources :info, only: [:index] do
        collection do
          get :matches
        end
      end
      resources :actions, only: [] do
        collection do
          post :sync
        end
      end
    end
  end
end
