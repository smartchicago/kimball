Logan::Application.routes.draw do
  devise_for :users
  resources :comments

  get "search/index"
  resources :people do
    resources :comments
  end
  root to: 'people#index'
end
