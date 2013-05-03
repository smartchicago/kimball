Logan::Application.routes.draw do
  get "dashboard/index"
  resources :submissions

  resources :comments

  get "search/index"
  resources :people do
    resources :comments
  end
  root to: 'dashboard#index'
end
