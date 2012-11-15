Portfolio::Application.routes.draw do
  devise_for :users, :only => [:sessions, :passwords]

  devise_scope :user do
    get '/login' => 'devise/sessions#new'
    delete '/logout' => 'devise/sessions#destroy'
    get '/reset-password' => 'devise/passwords#new', :as => 'reset_password'
  end

  resources :pages, :only => [:show]

  resources :posts, :only => [:index, :show]

  authenticate :user do
    namespace :admin do
      root :to => 'admin#index'

      resource :account, :only => [:show, :edit, :update]

      resources :pages

      resources :pictures do
        collection do
          get :selector
        end
      end

      resources :posts

      resources :users
    end
  end

  root :to => 'posts#index'

  get ':id' => 'pages#show'
end
