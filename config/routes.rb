Logan::Application.routes.draw do
  resources :submissions

  resources :comments

  get "search/index"
  resources :people do
    resources :comments
  end
  root to: 'people#index'
end
