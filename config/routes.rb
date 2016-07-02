Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users
  resources :images
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
