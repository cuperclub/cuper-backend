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
      sessions: "auth/sessions",
      registrations: "auth/registrations",
      passwords: "auth/passwords"
    }
  )

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do

    resources :companies, only: [:index]
    resources :promotions, only: [:index, :show]
    resource :users, only: [:update]
    resources :users, only: [:update]

    namespace :admin do
      resources :categories
      resources :companies, only: [:index, :show]
      resources :users do
        member do
          put :toggle_status
        end
        collection do
          get "/:role",
              to: "users#index"
        end
      end
    end

    namespace :partner do
      resource :company, only: [:create, :update, :show] do
        resources :promotions, only: [:index, :show]
      end
      resources :offices, only: [:index, :create, :show, :update] do
        member do
          put :toggle_status
        end
        resources :promotions, only: [:create, :update]
      end
      resources :employees, only: [:index, :show] do
        member do
          put :update_state
        end
      end
    end

    namespace :cashier do
      resource :profile, only: [:create]
    end

    resources :transaction_inputs, only: [:create]
    resources :transaction_outputs, only: [:create]
  end
end
