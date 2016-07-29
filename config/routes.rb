Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  resources :posts
  resources :users
  root to: 'posts#index'

  get '/map', to: 'users#map'
  
  scope module: :api, defaults: {format: 'json'} do
    namespace :v1 do
      # devise_for :users, :controllers => {sessions: 'api/sessions'}#, registrations: 'api/registrations'
      resources :users
      resources :posts
 
      devise_scope :user do
        match '/sessions' => 'sessions#create', via: :post
        match '/sessions' => 'sessions#destroy', via: :delete
      end
      
      get '/map', to: 'users#map'

    end
  end
end
