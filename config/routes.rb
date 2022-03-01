Rails.application.routes.draw do
  if Rails.env.development?
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end
  ActiveAdmin.routes(self)
  mount ActionCable.server, at: '/cable'

  # Used for password reset
  resources :passwords, controller: 'passwords',
                        only: [:create, :new, :edit, :update]
  # Used for `session_path` for login helper
  resource :session, controller: 'sessions', only: [:create]

  # Seemingly still used for some user changes
  resources :users, controller: 'users', only: [:create] do
    resource :password,
             controller: 'clearance/passwords',
             only: [:create, :edit]
    resource :password,
             controller: 'passwords',
             only: [:update]
  end

  get '/sign_in' => 'sessions#new', as: 'sign_in'
  match '/sign_out' => 'sessions#destroy', as: 'sign_out', via: [:get, :delete]
  get '/sign_up' => 'users#new', as: 'sign_up'
  get '/confirm_email/:token' => 'email_confirmations#update',
      as: 'confirm_email'
  get '/resend_verification_instructions' => 'email_confirmations#create',
      as: 'resend_verification_instructions'

  get '/welcome' => 'welcome#index'
  get '/join' => 'home#index'

  root to: 'home#index'

  namespace :families, path: 'communities' do
    resources :ownership_transfers, only: [:show, :update] do
      get :decline_invitation, on: :member
    end
  end

  namespace :vaults do
    get ':vault_id/download', to: 'downloads#show'
  end
  namespace :stories do
    get ':story_id/download', to: 'downloads#show'
  end

  resources :users, only: [:new, :create, :update] do
    collection do
      delete :destroy
    end
  end

  resources :invitations, only: [] do
    get :decline, on: :member
  end

  # Temp. remove payment feature
  # namespace :billing do
  #   resources :cards, only: [:new, :create]
  # end

  # post '/subscriptions/webhooks' => 'subscriptions#webhook'
  # post '/subscriptions/cancel' =>
  #   'subscriptions#cancel', as: :cancel_subscription
  # post '/subscriptions/resume' =>
  #   'subscriptions#resume', as: :resume_subscription
  # post '/subscriptions/renew' =>
  #   'subscriptions#renew', as: :renew_subscription

  get '/account' => 'accounts#show', as: :account
  get '/pages/*id' => 'pages#show', as: :page, format: false
  get 'templates/*id' => 'templates#show', as: :template
  get 'admin' => 'admin#index'
  get '/signup', to: redirect('/sign_up')
  get '/landing' => 'users#new', as: 'landing'

  namespace :api do
    namespace :v1 do
      resource :ownership_transfer, only: [:new, :create]

      resources :vaults, only: [:index, :show] do
        scope module: :vaults do
          resources :boxes, only: [:show, :create, :update]
          resource :items, only: :destroy
        end
        resources :attachments, only: [:create, :update], controller: 'vaults/attachments' do
          collection do
            post :move
            post :copy
            get :upload_config
          end
        end
      end

      namespace :billing do
        post '/invoice_status_changed', to: 'callbacks#invoice_status_changed'
        post '/store_any_event', to: 'callbacks#store_any_event'
      end

      resources :kinships, only: [:show, :update, :destroy] do
        get '/by_family/:family_id' => 'kinships#show_by_family', on: :collection
        get '/kinship_data' => 'kinships#kinship_data', on: :collection
        get :upload_config, on: :member
        scope module: :kinships do
          resource :role, only: [:update]
          resource :offline_member, only: [:update]
          resource :invitation, only: [:create]
        end
      end

      resources :invitations, only: [:show, :update]
      resource :invitations, only: [:destroy]

      resources :families, only: [:index, :update, :show, :create, :destroy] do
        scope module: :families do
          namespace :invitations do
            resource :resend, only: [:create]
          end
          resources :invitations, only: [:index, :create]
        end
        resources :kinships, only: [:index], controller: 'families/kinships'
        resources :offline_members, only: [:create, :update], controller: 'families/offline_members'
        get '/quick_list' => 'families#quick_list', on: :collection
      end
      resources :chapters, only: [:index, :create, :destroy, :update]
      get '/table_content_list', to: 'chapters#table_content_list'
      resources :media_files, only: [:create] do
        get :upload_config, on: :collection
      end

      resources :publications, only: [:index, :show] do
        scope module: :publications do
          resources :comments, only: [:create, :destroy]
          resources :appreciations, only: [:create, :destroy]
        end
      end

      resources :stories, only: [:create, :update, :destroy] do
        member do
          post :duplicate
          post :notify
          get :chapter_links
          get :upload_config
        end

        resources :sections, only: [:index, :create, :update, :destroy]
        resources :publications, only: [:create, :destroy]
      end

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
