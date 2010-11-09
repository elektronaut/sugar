Sugar::Application.routes.draw do

	# Search discussions
	match '/search/:query.:format' => 'discussions#search', :as => :formatted_search_with_query
	match '/search/:query'         => 'discussions#search', :as => :search_with_query
	match '/search'                => 'discussions#search', :as => :search

	# Search posts
	match '/posts/search/:query' => 'posts#search'
	match '/posts/search' => 'posts#search', :as => :search_posts

	# Search posts in discussion
	match '/discussions/:id/search_posts/:query' => 'discussions#search_posts'

	# Users
	resources :users do
		member do
			#get 'participated'
			#get 'discussions'
			#get 'posts'
			#get 'update_openid'
			#get 'grant_invite'
			#get 'revoke_invites'
			#get 'stats'
		end
		collection do
			get 'login'
			post 'login'
			get 'logout'
			get 'password_reset'
			post 'password_reset'
			get 'complete_openid_login'
			get 'facebook_login'
			get 'connect_facebook'
			get 'disconnect_facebook'

			get 'xboxlive'
			get 'twitter'
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
		match '/users/profile/:id/grant_invite'       => :grant_invite,   :as => :grant_invite_user
		match '/users/profile/:id/revoke_invites'     => :revoke_invites, :as => :revoke_invites_user
		match '/users/profile/:id/update_openid'      => :update_openid,  :as => :update_openid_user
		match '/users/profile/:id/edit'               => :edit,           :as => :edit_user
		match '/users/profile/:id/edit/:page'         => :edit,           :as => :edit_user_page
		match '/users/profile/:id'                    => :show,           :as => :user_profile
		match '/users/profile/:id/discussions'        => :discussions,    :as => :discussions_user
		match '/users/profile/:id/discussions/:page'  => :discussions
		match '/users/profile/:id/participated'       => :participated,   :as => :participated_user
		match '/users/profile/:id/participated/:page' => :participated
		match '/users/profile/:id/posts'              => :posts,          :as => :posts_user
		match '/users/profile/:id/posts/:page'        => :posts,          :as => :paged_user_posts
		match '/users/profile/:id/stats'              => :stats,          :as => :stats_user
		match '/users/new/:token'                     => :new,            :as => :new_user_by_token
	end

	# Categories
	resources :categories
    match '/categories/:id/:page' => 'categories#show'

	# Discussions
	controller :discussions do
		match '/discussions/popular/:days/:page'  => :popular
		match '/discussions/popular/:days'        => :popular
		match '/discussions/archive/:page'        => :index,         :as => :paged_discussions
		match '/discussions/:id/:page'            => :show,          :as => :paged_discussion
		match '/conversations/new'                => :new,           :as => :new_conversation, :type => 'conversation'
		match '/conversations/new/with/:username' => :new,           :as => :new_conversation_with, :type => 'conversation'
		match '/conversations/archive/:page'      => :conversations, :as => :paged_conversations
	end
	match '/discussions/:discussion_id/posts/since/:index' => 'posts#since'
	match '/conversations' => 'discussions#conversations', :as => :conversations
	resources :discussions do
		member do
			get 'follow'
			get 'unfollow'
			get 'favorite'
			get 'unfavorite'
			get 'search_posts'
			get 'mark_as_read'
			post 'invite_participant'
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

	# Vanilla redirects
	controller :vanilla do
		match '/vanilla'              => :discussions
		match '/vanilla/index.php'    => :discussions
		match '/vanilla/comments.php' => :discussion
		match '/vanilla/account.php'  => :user
	end

	# This is a legacy wild controller route that's not recommended for RESTful applications.
	# Note: This route will make all actions in every controller accessible via GET requests.
	#match ':controller(/:action(/:id(.:format)))'

	# Root
	root :to => "discussions#index"

end