# encoding: utf-8

Sugar::Application.routes.draw do

  use_doorkeeper

  # API routes
  namespace :api, :defaults => {:format => 'json'} do
    scope :module => :v1 do
      resources :users do
        collection do
          get 'me'
        end
      end
    end
  end

  # OpenID
  resource :openid, :controller => 'openid' do
    member do
      get 'complete'
    end
  end

  # Facebook
  resource :facebook, :controller => 'facebook' do
    member do
      get 'login'
      get 'signup'
      get 'connect'
      post 'disconnect'
    end
  end

  # Search discussions
  get '/search/:query.:format' => 'discussions#search', as: :formatted_search_with_query
  get '/search/:query'         => 'discussions#search', as: :search_with_query
  match '/search'              => 'discussions#search', as: :search, via: [:get, :post]

  # Search posts
  get '/posts/search/:query' => 'posts#search'
  match '/posts/search' => 'posts#search', :as => :search_posts, via: [:get, :post]

  # Search posts in discussion
  match '/discussions/:id/search_posts/:query' => 'discussions#search_posts', via: [:get, :post]

  # Users
  resources :users, except: [:edit, :show] do
    collection do
      get 'login'
      post 'authenticate'
      get 'logout'
      get 'password_reset'
      post 'deliver_password'
      get 'connect_facebook'
      get 'disconnect_facebook'

      get 'xboxlive'
      get 'social'
      get 'online'
      get 'recently_joined'
      get 'admins'
      get 'top_posters'
      get 'trusted'
      get 'map'
      get 'banned'
    end
  end

  controller :users do
    post '/users/profile/:id/grant_invite'       => :grant_invite,   :as => :grant_invite_user
    post '/users/profile/:id/revoke_invites'     => :revoke_invites, :as => :revoke_invites_user
    get  '/users/profile/:id/update_openid'      => :update_openid,  :as => :update_openid_user
    get  '/users/profile/:id/edit'               => :edit,           :as => :edit_user
    get  '/users/profile/:id/edit/:page'         => :edit,           :as => :edit_user_page
    get  '/users/profile/:id'                    => :show,           :as => :user_profile
    get  '/users/profile/:id/discussions'        => :discussions,    :as => :discussions_user
    get  '/users/profile/:id/discussions/:page'  => :discussions
    get  '/users/profile/:id/participated'       => :participated,   :as => :participated_user
    get  '/users/profile/:id/participated/:page' => :participated
    get  '/users/profile/:id/posts'              => :posts,          :as => :posts_user
    get  '/users/profile/:id/posts/:page'        => :posts,          :as => :paged_user_posts
    get  '/users/profile/:id/stats'              => :stats,          :as => :stats_user
    get  '/users/new/:token'                     => :new,            :as => :new_user_by_token
  end

  resources :password_resets, :only => [:new, :create, :show, :update]
  controller :password_resets do
    get '/password_resets/:id/:token' => :show, :as => :password_reset_with_token
  end

  # Categories
  resources :categories
  get '/categories/:id/:page' => 'categories#show'

  # Discussions
  controller :discussions do
    get '/discussions/popular/:days/:page'  => :popular
    get '/discussions/popular/:days'        => :popular
    get '/discussions/archive/:page'        => :index,         :as => :paged_discussions
    get '/conversations/new'                => :new,           :as => :new_conversation, :type => 'conversation'
    get '/conversations/new/with/:username' => :new,           :as => :new_conversation_with, :type => 'conversation'
    get '/conversations/archive/:page'      => :conversations, :as => :paged_conversations
  end
  resources :discussions do
    member do
      get 'follow'
      get 'unfollow'
      get 'favorite'
      get 'unfavorite'
      get 'search_posts'
      get 'mark_as_read'
      post 'invite_participant'
      delete 'remove_participant'
    end
    collection do
      get 'participated'
      get 'search'
      get 'following'
      get 'favorites'
      get 'conversations'
      get 'popular'
    end

    # Posts
    resources :posts do
      member do
        get 'quote'
      end
      collection do
        post 'doodle'
        get  'count'
        get  'since'
        post 'preview'
      end
    end
  end
  get '/discussions/:id/:page' => 'discussions#show', :as => :paged_discussion
  get '/discussions/:discussion_id/posts/since/:index' => 'posts#since'
  get '/conversations' => 'discussions#conversations', :as => :conversations


  # Invites
  resources :invites do
    member do
      get :accept
    end
    collection do
      get :all
    end
  end

  # Admin
  resource :admin, :controller => 'admin' do
    get 'configuration', :on => :member
    post 'configuration', :on => :member
  end

  # Help pages
  get 'help' => 'help#index', :as => :help
  get 'help/:page' => 'help#show', :as => :help_page

  # Vanilla redirects
  controller :vanilla do
    get '/vanilla'              => :discussions
    get '/vanilla/index.php'    => :discussions
    get '/vanilla/comments.php' => :discussion
    get '/vanilla/account.php'  => :user
  end

  # Root
  root :to => "discussions#index"

end
