Logan::Application.routes.draw do
  resources :gift_cards
  resources :mailchimp_updates
  namespace :public do
    resources :people, only: [:new, :create, :deactivate] do
      get '/deactivate/:token', to:'people#deactivate', as: :deactivate
    end
  end

  namespace :v2 do
    resources :event_invitations
    resources :reservations do
      collection do
        post ':id/confirm/(:token)',
              to: 'reservations#confirm',
              as: :confirm
        post ':id/cancel/(:token)',
              to: 'reservations#cancel',
              as: :cancel
        post ':id/change/(:token)',
              to: 'reservations#change',
              as: :change
        get ':id/confirm/(:token)',
              to: 'reservations#confirm',
              as: :remote_confirm
        get ':id/cancel/(:token)',
              to: 'reservations#cancel',
              as: :remote_cancel
        get ':id/change/(:token)',
              to: 'reservations#change',
              as: :remote_change
      end
      resources :comments, controller: '/comments'
    end
    resources :sms_reservations, only: [:create]
  end

  # simple session based cart for storing people ids.
  get 'v2/cart', to: 'v2/cart#index', as: :show_cart
  get 'v2/cart/add/:person_id', to: 'v2/cart#add', as: :add_cart
  get 'v2/cart/delete(/:person_id(/:all))', to: 'v2/cart#delete', as: :delete_cart

  get 'registration', to: 'public/people#new'

  resources :twilio_wufoos

  resources :twilio_messages do
    collection do
      post 'newtwil'
      get 'newtwil'
      post 'uploadnumbers'
      get 'sendmessages'
    end
  end

  post 'receive_text/index', defaults: { format: 'xml' }
  post 'receive_text/smssignup', defaults: { format: 'xml' }

  # post "twilio_messages/updatestatus", to: 'twilio_messages/#updatestatus'

  # post "twil", to: 'twilio_messages/#newtwil'

  get 'taggings/create'
  get 'taggings/destroy'
  get 'taggings/search'

  get 'mailchimp_export/index'
  get 'mailchimp_export/create'
  resources :reservations

  resources :events do
    member do
      post :export
    end
  end

  resources :applications


  resources :programs

  devise_for :users
  get 'dashboard/index'
  resources :submissions

  resources :comments
  resources :taggings, only: [:create, :destroy]

  get 'calendar/event_slots.json(:token)', to: 'calendar#event_slots', defaults: { format: 'json' }

  get 'calendar/reservations.json(:token)', to: 'calendar#reservations', defaults: { format: 'json' }
  get 'calendar/events.json', to: 'calendar#events', defaults: { format: 'json' }

  get '/calendar/(:id)', to: 'calendar#show', as: :calendar
  get '/calendar/(:token)/feed/', to: 'calendar#feed', defaults: { format: 'ics' }
  get '/calendar/show_actions/:id/(:token)',
      to: 'calendar#show_actions',
      defaults: { format: 'js' },
      as: :calendar_show_actions

  get '/calendar/show_reservation/:id/(:token)',
      to: 'calendar#show_reservation',
      defaults: { format: 'js' },
      as: :calendar_show_reservation

  get '/calendar/show_invitation/:id/(:token)',
      to: 'calendar#show_invitation',
      defaults: { format: 'js' },
      as: :calendar_show_invitation

  get '/calendar/show_event/:id/(:token)',
      to: 'calendar#show_event',
      defaults: { format: 'js' },
      as: :calendar_show_event



  get  'search/index'
  get  'search/index_ransack'
  post 'search/index_ransack'
  post 'search/export_ransack'
  post 'search/export' # send search results elsewhere, i.e. Mailchimp
  post 'search/exportTwilio'

  get 'mailchimp_exports/index'

  resources :people do
    collection do
      post 'create_sms'
      post ':person_id/deactivate', action: :deactivate, as: :deactivate
    end
    resources :comments
    resources :gift_cards
  end
  # post "people/create_sms"


  root to: 'dashboard#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
