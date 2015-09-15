Logan::Application.routes.draw do
  resources :twilio_messages do
    collection do
      post 'newtwil'
      get 'newtwil'
    end
  end

  post "receive_text/index",  defaults: { format: 'xml' }
  post "receive_text/smssignup",  defaults: { format: 'xml' }

  #post "twilio_messages/updatestatus", to: 'twilio_messages/#updatestatus'
  
  #post "twil", to: 'twilio_messages/#newtwil'

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
  post "people/create_sms"

  root to: 'dashboard#index'
end
