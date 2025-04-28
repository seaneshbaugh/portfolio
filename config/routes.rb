Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  devise_for :users, skip: %i[sessions passwords registrations confirmations unlocks]

  devise_scope :user do
    get "/login" => "devise/sessions#new", as: :new_user_session
    post "/login" => "devise/sessions#create", as: :user_session
    delete "/logout" => "devise/sessions#destroy", as: :destroy_user_session

    post "/update-password" => "devise/passwords#create", as: :user_password
    get "/reset-password" => "devise/passwords#new", as: :new_user_password
    get "/update-password" => "devise/passwords#edit", as: :edit_user_password
    put "/update-password" => "devise/passwords#update"
  end

  get "/contact" => "contact#new", as: :contact

  post "/contact" => "contact#create"

  resources :posts, only: %i[show]

  resources :pictures, only: %i[index show]

  get "/links" => "links#index", as: :links
  get "/links/:year" => "links#index"
  get "/links/:year/:month" => "links#index"

  get "/posts.rss" => "posts#index", format: :rss

  get "/sitemap.xml" => "sitemap#index", as: :sitemap, format: :xml

  namespace :api do
    namespace :v1 do
      resources :pictures, only: %i[index show]
      resources :posts, only: %i[index show]
      resources :tags, only: %i[index]
    end
  end

  authenticate :user do
    namespace :admin do
      root to: "admin#index"

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

      get "/tags.json" => "tags#index"
    end

    post "versions/:id/revert" => "versions#revert", as: :revert_version
  end

  # Defines the root path route ("/")
  root "posts#index"

  get ":id" => "pages#show", as: :page
end
