Rails.application.routes.draw do
  root to: redirect("/apipie")
  apipie

  resources :transaction_outputs
  resources :transaction_inputs

  # mount_devise_token_auth_for 'User', at: 'auth'

  mount_devise_token_auth_for(
    "User",
    at: "auth",
    controllers: {
      passwords: "auth/passwords"
    }
  )

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do

    resources :companies, only: [:index]
    resources :promotions, only: [:index, :show]

    namespace :admin do
      resources :categories
      resources :companies, only: [:index, :show]
      resources :users do
        collection do
          get "/:role",
              to: "users#index"
        end
      end
    end

    namespace :partner do
      resource :company, only: [:update, :show] do
        resources :promotions, only: [:index, :show]
      end
      resources :offices, only: [:index, :create, :show, :update] do
        resources :promotions, only: [:create, :update]
      end
      resources :employees, only: [:index, :show] do
        member do
          put :update_state
        end
      end
    end
  end
end
