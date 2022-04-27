Rails.application.routes.draw do
  if Rails.env.development?
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end
  ActiveAdmin.routes(self)
  mount ActionCable.server, at: '/cable'

  root to: 'home#index'

  # Used for password reset
  resources :passwords, controller: 'passwords', only: [:create, :new, :edit, :update]
  # Used for `session_path` for login helper
  resource :session, controller: 'sessions', only: [:create]

  # Seemingly still used for some user changes
  resources :users, controller: 'users', only: [:create] do
    resource :password, controller: 'clearance/passwords', only: [:create, :edit]
    resource :password, controller: 'passwords', only: [:update]
  end

  get '/sign_in' => 'sessions#new'
  match '/sign_out' => 'sessions#destroy', via: [:get, :delete]
  get '/sign_up' => 'users#new'
  get '/signup' => 'users#new_alternative'
  get '/confirm_email/:token' => 'email_confirmations#update', as: 'confirm_email'
  get '/resend_verification_instructions' => 'email_confirmations#create'
  get '/subscriptions' => 'subscriptions#show'
  post '/subscriptions/webhooks' => 'subscriptions#webhook'
  get '/account' => 'accounts#show'
  get '/pages/*id' => 'pages#show', as: :page, format: false
  get 'admin' => 'admin#index'
  get '/landing' => 'users#new'

  namespace :families, path: 'communities' do
    resources :ownership_transfers, only: [:show, :update] do
      get :decline_invitation, on: :member
    end
  end

  namespace :vaults do
    get ':vault_id/download', to: 'downloads#show'
  end
  namespace :publications do
    get ':publication_id/download', to: 'downloads#show'
  end

  resources :users, only: [:new, :create, :update] do
    collection do
      delete :destroy
    end
  end

  resources :invitations, only: [] do
    get :decline, on: :member
  end

  namespace :api do
    namespace :v1 do
      post '/sign_in' => 'sign_in#create'
      post '/sign_up' => 'sign_up#create'
      resource :ownership_transfer, only: [:new, :create]
      resources :categories, only: [:index]

      resources :vaults, only: [:index, :show] do
        scope module: :vaults do
          resources :boxes, only: [:show, :create, :update]
          resource :items, only: [:destroy]
          resources :items, only: [:index]
        end
        resources :attachments, only: [:create, :update], controller: 'vaults/attachments' do
          collection do
            post :move
            post :copy
          end
        end
      end

      namespace :messages do
        resources :recipients, only: [:index]
      end
      namespace :billing do
        post '/invoice_status_changed', to: 'callbacks#invoice_status_changed'
        post '/store_any_event', to: 'callbacks#store_any_event'
      end

      resources :kinships, only: [:show, :update, :destroy] do
        get '/by_family/:family_id' => 'kinships#show_by_family', on: :collection
        get '/kinship_data' => 'kinships#kinship_data', on: :collection
        post :notify, on: :member
        scope module: :kinships do
          resource :role, only: [:update]
          resource :offline_member, only: [:update]
          resource :invitation, only: [:create]
        end
      end

      resources :received_invitations, only: [:index]
      resources :invitations, only: [:show, :update]
      resource :invitations, only: [:destroy] do
        scope module: :invitations do
          resource :resend, only: [:create]
        end
      end

      resources :followers, only: [:index]
      resources :followings, only: [:index, :show, :destroy]
      resources :families, only: [:index, :update, :show, :create, :destroy] do
        get :quick_list, on: :collection

        scope module: :families do
          resources :kinships, only: [:index]
          resources :offline_members, only: [:create, :update]
          resources :invitations, only: [:index, :create]
        end
      end
      resources :appreciations, only: [:create, :destroy]
      resources :comments, only: [:create, :destroy]
      resources :chapters, only: [:index, :create, :destroy, :update]
      get '/table_content_list', to: 'chapters#table_content_list'

      resources :publications, only: [:index, :show, :create, :destroy] do
        scope module: :publications do
          resources :sections, only: [:index, :create, :update, :destroy]
          resources :families, only: [:index]
          resource :story, only: [:create, :update, :destroy] do
            member do
              post :duplicate
              post :notify
              get :chapter_links
            end
          end
        end
      end

      resource :story, only: [:create]

      resources :requests, only: [:create]
      resource :user, only: [:update]
    end
  end

  get '/*path', to: 'vue#show',
                format: false,
                constraints: ->(req) do
                  req.path.exclude? 'rails/active_storage'
                end
end
