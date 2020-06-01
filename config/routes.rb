# -*- encoding : utf-8 -*-
Redu::Application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'

  localized do
    get 'getpdf', to: 'lectures#getpdf'
    match '/oauth/token',         :to => 'oauth#token',         :as => :token
    match '/oauth/access_token',  :to => 'oauth#access_token',  :as => :access_token
    match '/oauth/request_token', :to => 'oauth#request_token', :as => :request_token
    match '/oauth/authorize',     :to => 'oauth#authorize',     :as => :authorize
    match '/oauth',               :to => 'oauth#index',         :as => :oauth
    match '/oauth/revoke', :to => 'oauth#revoke'
    match '/oauth/revoke',        :to => 'oauth#revoke',        :as => :oauth_revoke
    match '/oauth/invalidate',    :to => 'oauth#invalidate',    :as => :oauth_invalidate
    match '/oauth/capabilities',  :to => 'oauth#capabilities',  :as => :oauth_capabilities

    match '/analytics/dashboard', :to => 'analytics_dashboard#dashboard'
    match '/analytics/signup_by_date', :to => 'analytics_dashboard#signup_by_date'
    match '/analytics/environment_by_date', :to => 'analytics_dashboard#environment_by_date'
    match '/analytics/course_by_date', :to => 'analytics_dashboard#course_by_date'
    match '/analytics/post_by_date', :to => 'analytics_dashboard#post_by_date'

    match '/search' => 'search#index', :as => :search
    # Rota para todos os ambientes em geral e quando houver mais de um filtro selecionado
    match '/search/environments' => 'search#environments', :as => :search_environments
    match '/search/profiles' => 'search#profiles', :as => :search_profiles

    get "vis/dashboard/teacher_participation_interaction"

    match '/jobs/notify' => 'jobs#notify', :as => :notify
    resources :statuses, :only => [:show, :create, :destroy] do
      member do
        post :respond
      end
    end

    #chat routes
    post 'chat/send_message', to: 'chats#send_message'
    get 'chat/online', to: 'chats#online'
    get 'chat/last_messages_with', to: 'chats#last_messages_with'

    # sessions routes
    match '/signup' => 'users#new', :as => :signup
    get '/login' => 'sessions#new', :as => :login
    match '/logout' => 'sessions#destroy', :as => :logout

    # Authentications
    resources :authentications, :only => [:create]
    get '/auth/:provider/callback' => 'authentications#create', :as => :omniauth_auth
    get '/auth/failure' => 'authentications#fallback', :as => :omniauth_fallback
    get 'auth/facebook', :as => :facebook_authentication

    get '/recover_username_password' => 'users#recover_username_password',
      :as => :recover_username_password
    post '/recover_password' => 'users#recover_password', :as => :recover_password
    get '/confirm_recover_password/:token',
     to: 'users#confirm_recover_password',
     as: :confirm_recover_password

    match '/resend_activation' => 'users#resend_activation',
      :as => :resend_activation
    match '/account/edit' => 'users#edit_account', :as => :edit_account_from_email
    resources :sessions, :only => [:new, :create, :destroy]

    # site routes
    match '/about' => 'base#about', :as => :about
    match 'contact' => 'base#contact', :as => :contact

    # Space
    resources :spaces, :except => [:index] do
      member do
        get :admin_members
        get :mural
        get :students_endless
        get :admin_subjects
        get :subject_participation_report
        get :lecture_participation_report
        get :students_participation_report
        get :students_participation_report_show
      end

      resources :folders, :only => [:update, :create, :index] do
        member do
          get :download
          delete :destroy_folder
          delete :destroy_file
          post :do_the_upload
        end
      end

      resources :subjects, :except => [:index] do
        resources :lectures do
          member do
            post :rate
            post :done
            get :page_content
          end
        end
      end

      resources :users, :only => [:index]
      resources :canvas, :only => [:show]
   end

    resources :exercises, :only => :show do
      resources :results, :only => [:index, :create, :update, :edit]
      resources :questions, :only => :show do
        resources :choices, :only => [:create, :update]
      end
    end

    #Invitations
    resources :invitations, :only => [:show, :destroy] do
      member do
        post :resend_email
      end
      collection do
        post :destroy_invitations
      end
    end

    # Users
    resources :users, :except => [:index] do
      member do
        get :edit_account
        put :update_account
        get :forgot_password
        post :forgot_password
        get :signup_completed
        get :invite
        put :deactivate
        get :home
        get :my_wall
        get :account
        get :contacts_endless
        get :environments_endless
        get :show_mural
        get :curriculum
      end

      collection do
        get :auto_complete
      end

      resources :social_networks, :only => [:destroy]

      resources :friendships, :only => [:index, :create, :destroy, :new] do
        member do
          post :resend_email
        end
      end

      resources :messages, :except => [:destroy, :edit, :update] do
        collection do
          get :index_sent
          post :delete_selected
        end
      end

      resources :plans, :only => [:index]
      resources :experiences
      resources :educations, :except => [:new, :edit]
      resources :environments, :only => [:index]
      resource :explore_tour, :only => :create
      resources :oauth_clients
    end

    resources :oauth_clients, :only => :new

    match 'users/activate/:id' => 'users#activate', :as => :activate

    # Indexes
    match 'contact' => "base#contact", :as => :contact
    match '/teach' => 'base#teach_index', :as => :teach_index
    get '/environments' => 'environments#index', :as => :environments_index

    resources :plans, :only => [] do
      member do
        get :confirm
        post :confirm
        get :options
      end

      resources :invoices, :only => [:index, :show] do
        member do
          post :pay
        end
      end
    end

    match '/payment/callback' => 'payment_gateway#callback',
      :as => :payment_callback
    match '/payment/success' => 'payment_gateway#success', :as => :payment_success

    resources :environments, :path => '', :except => [:index] do
      member do
        get :preview
        get :admin_courses
        get :admin_members
        post :destroy_members
        post :search_users_admin
      end
      resources :courses do
        member do
          get :preview
          get :admin_spaces
          get :admin_members_requests
          get :admin_invitations
          get :admin_manage_invitations
          get :teacher_participation_report
          post :invite_members
          post :accept
          post :join
          post :unjoin
          get :publish
          get :unpublish
          get :admin_members
          post :destroy_members
          post :destroy_invitations
          post :search_users_admin
          post :moderate_members_requests
          post :accept
          post :deny
        end

        resources :users, :only => [:index]
        resources :users, :only => :show do
          match :roles, :to => 'roles#update', :via => :post, :as => :roles
        end
        resources :user_course_invitations, :only => [:show]
        resources :plans, :only => [:create]
      end

      resources :users, :only => [:index]
      resources :users, :only => :show do
        resources :roles, :only => :index
        match :roles, :to => 'roles#update', :via => :post, :as => :roles
      end
      resources :plans, :only => [:create]
    end

    resources :pages, :only => :show

    root :to => 'base#site_index', :as => :home
    root :to => "base#site_index", :as => :application
  end

  namespace 'api', :defaults => { :format => 'json' } do
    resources :environments, :except => [:new, :edit] do
      resources :courses, :except => [:new, :edit], :shallow => true
      resources :users, :only => :index
    end

    resources :courses, :except => [:new, :edit, :index, :create] do
      resources :spaces, :except => [:new, :edit], :shallow => true
      resources :users, :only => :index
      resources :course_enrollments, :only => [:create, :index],
        :path => 'enrollments', :as => 'enrollments'
    end

    resources :course_enrollments, :only => [:show, :destroy],
        :path => 'enrollments', :as => 'enrollments'

    resources :spaces, :except => [:new, :edit, :index, :create] do
      resources :subjects, :only => [:create, :index]
      resources :users, :only => :index
      resources :statuses, :only => [:index, :create] do
        get 'timeline', :on => :collection
      end
      resources :folders, :only => :index
      resources :canvas, :only => [:create, :index]
    end

    resources :subjects, :except => [:new, :edit, :index, :create] do
      resources :lectures, :only => [:create, :index]
      resources :asset_reports, :path => "progress", :only => [:index]
    end

    resources :lectures, :except => [:new, :edit, :index, :create] do
      resources :user, :only => :index
      resources :statuses, :only => [:index, :create]
      resources :asset_reports, :path => "progress", :only => [:index]
    end

    resources :users, :only => :show do
      resources :course_enrollments, :only => :index, :path => :enrollments,
        :as => 'enrollments'
      resources :spaces, :only => :index
      resources :statuses, :only => [:index, :create] do
        get 'timeline', :on => :collection
      end
      resources :users, :only => :index, :path => :contacts,
        :as => :contacts
      resources :friendships, :path => :connections,
        :as => 'connections', :only => [:index, :create]
      resources :asset_reports, :path => "progress", :only => [:index]
    end

    match 'me' => 'users#show'

    resources :statuses, :only => [:show, :destroy] do
      resources :answers, :only => [:index, :create]
    end


    resources :folders, :only => [:show, :index] do
      resources :myfiles, :path => "files", :only => [:index, :create]
      resources :folders, :only => [:index, :create]
    end

    resources :folders, :only => [:update, :destroy]

    resources :myfiles, :path => "files", :only => [:show, :destroy]
    resources :canvas, :only => [:show, :update, :destroy]
    resources :asset_reports, :path => "progress", :only => [:show, :update]

    resources :friendships, :path => "connections",
      :only => [:show, :update, :destroy]

    match "vis/spaces/:space_id/lecture_participation",
      :to => 'vis#lecture_participation',
      :as => :vis_lecture_participation
    match "vis/spaces/:space_id/subject_activities",
      :to => 'vis#subject_activities',
      :as => :vis_subject_activities
    match "vis/spaces/:space_id/students_participation",
      :to => 'vis#students_participation',
      :as => :vis_students_participation

    # Captura exceções ActionController::RoutingError
    match '/404', :to => 'api#routing_error'
  end
end
