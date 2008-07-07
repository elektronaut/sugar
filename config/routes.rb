ActionController::Routing::Routes.draw do |map|
    # The priority is based upon order of creation: first created -> highest priority.

    # Sample of regular route:
    #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
    # Keep in mind you can assign values other than :controller and :action

    # Sample of named route:
    #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
    # This route can be invoked with purchase_url(:id => product.id)

    # Sample resource route (maps HTTP verbs to controller actions automatically):
    #   map.resources :products

    # Sample resource route with options:
    #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

    # Sample resource route with sub-resources:
    #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

    # Sample resource route with more complex sub-resources
    #   map.resources :products do |products|
    #     products.resources :comments
    #     products.resources :sales, :collection => { :recent => :get }
    #   end

    # Sample resource route within a namespace:
    #   map.namespace :admin do |admin|
    #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
    #     admin.resources :products
    #   end

    # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
    # map.root :controller => "welcome"

    # See how all your routes lay out with "rake routes"
    
    map.connect '/search/:query', :controller => 'discussions', :action => 'search'
    map.search '/search', :controller => 'discussions', :action => 'search'

    map.resources(
        :users,
        :member => {:participated => :any},
        :collection => { :login => :any, :logout => :any, :forgot_password => :any }
    )
    map.connect '/users/:id/participated/:page', :controller => 'users', :action => 'participated'

    map.resources(
        :categories
    )
    map.connect '/categories/:id/:page', :controller => 'categories', :action => 'show'

    map.resources(
        :messages,
        :collection => { :outbox => :any, :conversations => :any }
    )
    map.paged_messages '/messages/inbox/:page', :controller => 'messages', :action => 'index'
    map.paged_sent_messages '/messages/outbox/:page', :controller => 'messages', :action => 'outbox'
    map.user_conversation '/messages/conversations/:username', :controller => 'messages', :action => 'conversations'
    map.paged_user_conversation '/messages/conversations/:username/:page', :controller => 'messages', :action => 'conversations'
    map.last_user_conversation_page '/messages/conversations/:username/last', :controller => 'messages', :action => 'conversations', :page => :last

    map.resources(
        :discussions,
        :collection => { :participated => :any, :bookmarked => :any, :search => :any }
    ) do |discussions|
        discussions.resources(
            :posts,
            :member => { :quote => :any },
            :collection => { :doodle => :post }
        )
    end
    map.paged_discussions '/discussions/archive/:page', :controller => 'discussions', :action => 'index'
    map.paged_discussion  '/discussions/:id/:page', :controller => 'discussions', :action => 'show'

    # Vanilla redirects
    map.with_options :controller => 'vanilla' do |vanilla|
        vanilla.connect '/vanilla', :action => 'discussions'
        vanilla.connect '/vanilla/index.php', :action => 'discussions'
        vanilla.connect '/vanilla/comments.php', :action => 'discussion'
        vanilla.connect '/vanilla/account.php', :action => 'user'
    end

    # Install the default routes as the lowest priority.
    map.connect ':controller/:action/:id'
    map.connect ':controller/:action/:id.:format'

    map.root :controller => 'discussions', :action => 'index'
end
