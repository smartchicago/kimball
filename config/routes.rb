Logan::Application.routes.draw do
  resources :twilio_messages

  get "taggings/create"
  get "taggings/destroy"
  get "mailchimp_export/index"
  get "mailchimp_export/create"
  resources :reservations

  resources :events do
    member do
      post :export
    end    
  end

  resources :applications

  resources :programs

  devise_for :users
  get "dashboard/index"
  resources :submissions

  resources :comments
  resources :taggings, only: [:create, :destroy]
  
  get  "search/index"
  post "search/export"  # send search results elsewhere, i.e. Mailchimp

  get "mailchimp_exports/index"
  
  resources :people do
    resources :comments
  end
  root to: 'dashboard#index'
end
