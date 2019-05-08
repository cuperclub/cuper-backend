Rails.application.routes.draw do
  root to: redirect("/apipie")
  apipie

  resources :transaction_outputs
  resources :transaction_inputs

  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do

    resources :companies, only: [:index]
    resources :promotions, only: [:index, :show]

    namespace :admin do
      resources :categories
      resources :companies, only: [:index, :show]
      resources :users, only: [:index]
    end

    namespace :partner do
      resource :company, only: [:update, :show]
      resources :offices, only: [:index, :create, :show, :update] do
        resources :promotions, only: [:index, :create, :show, :update]
      end
      resources :employees, only: [:index, :show] do
        member do
          put :update_state
        end
      end
    end
  end
end
