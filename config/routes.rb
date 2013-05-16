Logan::Application.routes.draw do
  get "mailchimp_export/index"
  get "mailchimp_export/create"
  resources :reservations

  resources :events

  resources :applications

  resources :programs

  devise_for :users
  get "dashboard/index"
  resources :submissions

  resources :comments

  get "search/index"

  resources :mailchimp_exports
  
  resources :people do
    resources :comments
  end
  root to: 'dashboard#index'
end
