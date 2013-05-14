Logan::Application.routes.draw do
  resources :reservations

  resources :events

  resources :applications

  resources :programs

  devise_for :users
  get "dashboard/index"
  resources :submissions

  resources :comments

  get "search/index"
  resources :people do
    resources :comments
  end
  root to: 'dashboard#index'
end
