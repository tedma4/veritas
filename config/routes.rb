Rails.application.routes.draw do
  devise_for :users, controllers: {sessions: "sessions"}
  # mount ActionCable.server => '/cable'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  resources :posts
  resources :users
  resources :areas
  root to: 'posts#index'
  get '/map',      to: 'users#map'
  get '/search',   to: 'users#search'
  get 'areas/feed/:id', to: 'areas#feed'
  
  scope module: :api, defaults: {format: 'json'} do
    namespace :v1 do
      mount ActionCable.server => '/cable'

      resources :users
      resources :posts
      resources :chats, only: [:create] do 
        resources :messages, only: [:create]
      end
 
      devise_scope :user do
        match '/sessions' => 'sessions#create', via: :post
        match '/sessions' => 'sessions#destroy', via: :delete
      end
      
      get '/map', to: 'users#map'
      get '/check_pin', to: 'users#check_pin'
      get '/search', to: 'users#search'
      get '/friend_list', to: 'users#friend_list'
      get '/feed', to: 'users#feed'
      post "/send_request", to: 'users#send_request'
      post "/approve_friend_request", to: 'users#approve_friend_request'
      post "/decline_friend_request", to: 'users#decline_friend_request'
      post "/remove_friend", to: 'users#remove_friend'
      get "/notifications", to: "notifications#index"
      post 'like', to: 'likes#like'
      delete 'unlike', to: 'likes#unlike'
      get 'memories', to: 'users#memories'
      get 'get_memories', to: 'users#get_memories'
      post 'user_location', to: 'users#user_location'

    end
  end
end
