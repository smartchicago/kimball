Logan::Application.routes.draw do
  resources :people
  root to: 'people#index'
end
