# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, skip: %i[sessions passwords registrations confirmations unlocks]

  devise_scope :user do
    get '/login' => 'devise/sessions#new', as: :new_user_session
    post '/login' => 'devise/sessions#create', as: :user_session
    delete '/logout' => 'devise/sessions#destroy', as: :destroy_user_session

    post '/update-password' => 'devise/passwords#create', as: :user_password
    get '/reset-password' => 'devise/passwords#new', as: :new_user_password
    get '/update-password' => 'devise/passwords#edit', as: :edit_user_password
    put '/update-password' => 'devise/passwords#update'
  end

  get '/contact' => 'contact#new', as: :contact

  post '/contact' => 'contact#create'

  resources :posts, only: %i[show]

  resources :pictures, only: %i[index show]

  get '/links' => 'links#index', as: :links
  get '/links/:year' => 'links#index'
  get '/links/:year/:month' => 'links#index'

  get '/posts.rss' => 'posts#index', format: :rss

  get '/sitemap.xml' => 'sitemap#index', as: :sitemap, format: :xml

  namespace :api do
    namespace :v1 do
      resources :pictures, only: %i[index show]
      resources :posts, only: %i[index show]
      resources :tags, only: %i[index]
    end
  end

  authenticate :user do
    namespace :admin do
      root to: 'admin#index'

      resource :account, only: %i[show edit update]

      resources :galleries

      resources :links

      resources :pages

      resources :pictures do
        collection do
          get :selector
        end
      end

      resources :posts

      resources :users

      get '/tags.json' => 'tags#index'
    end

    post 'versions/:id/revert' => 'versions#revert', as: :revert_version
  end

  root to: 'posts#index'

  get ':id' => 'pages#show', as: :page
end
