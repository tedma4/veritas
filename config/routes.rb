Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  resources :images
  resources :users
  root to: 'images#index'

  get '/map', to: 'users#map'
  
  scope module: :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :users
      resources :images
 
      devise_scope :user do
        match '/sessions' => 'sessions#create', via: :post
        match '/sessions' => 'sessions#destroy', via: :delete
      end
      get '/map', to: 'users#map'

    end
  end
end
