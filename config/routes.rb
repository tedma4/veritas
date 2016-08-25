Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  resources :posts
  resources :users
  root to: 'posts#index'

  get '/map',                       to: 'users#map'
  get '/search',                    to: 'users#search'
  post '/send_request',             to: 'users#send_request'
  post '/approve_request',          to: 'users#approve_request'
  delete '/remove_friend',          to: 'users#remove_friend'
  delete '/decline_request',        to: 'users#decline_request'
  
  get '/users/:id/friend_list',     to: 'users#friend_list'
  get '/users/:id/accept_requests', to: 'users#accept_requests'
  get '/users/:id/friends_posts',   to: 'users#friends_posts'
  
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
      get '/check_pin', to: 'users#check_pin'
      get '/search', to: 'users#search'
      get '/users/:id/friend_list', to: 'users#friend_list'

    end
  end
end
