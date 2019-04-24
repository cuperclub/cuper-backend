Rails.application.routes.draw do
  root to: redirect("/apipie")
  apipie

  resources :transaction_outputs
  resources :transaction_inputs
  resources :promotions
  resources :offices
  # resources :categories
  # resources :companies
  resources :employees
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do
    resources :categories
    resources :companies,
              only: [:create, :update, :show]
  end
end
