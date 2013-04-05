Logan::Application.routes.draw do
  get "search/index"
  resources :people
  root to: 'people#index'
end
