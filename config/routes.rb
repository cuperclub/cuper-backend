Rails.application.routes.draw do
  resources :transaction_outputs
  resources :transaction_inputs
  resources :promotions
  resources :offices
  resources :categories
  resources :companies
  resources :employees
  root to: redirect("/apipie")
  apipie
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
