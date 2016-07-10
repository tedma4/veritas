Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :images
  resources :users
  root to: 'images#index'
  # module :users do
  #   member do 
    get '/map', to: 'users#map'
  #   end
  # end
  # When Images need to be polymorphic, uncomment this
  # concern :imageable do
  #   resources :images
  # end
  
  scope module: :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :users
      resources :images
      get '/map', to: 'users#map'

    end
  end
end
