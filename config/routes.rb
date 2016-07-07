Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # resources :users
  resources :images
  root to: 'images#index'
  # When Images need to be polymorphic, uncomment this
  # concern :imageable do
  #   resources :images
  # end
  
  scope module: :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :users
      resources :images
    end
  end
end
