Logan::Application.routes.draw do
  resources :comments

  get "search/index"
  resources :people
  root to: 'people#index'
end
