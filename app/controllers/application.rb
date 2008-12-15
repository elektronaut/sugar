class ApplicationController < ActionController::Base

    helper :all # include all helpers, all the time

    session :session_expires => 3.years.from_now

    # See ActionController::RequestForgeryProtection for details
    # Uncomment the :secret if you're not using the cookie session store
    protect_from_forgery # :secret => '21e3d7f3d3c39ae82439f2f9108fc36b'
    filter_parameter_logging :password, :drawing

    layout 'default'


    # Misc. variables for the layout
    def layout_data
        @site_name = 'BUTT3RSCOTCH'
        case self.class.to_s
        when 'UsersController'
            @section = :users
        when 'CategoriesController'
            @section = :categories
        when 'MessagesController'
            @section = :messages
        else
            @section = :discussions
        end

		# Detect iphone
		@iphone_user_agent = (request.host =~ /^(iphone|m)\./ || (request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/])) ? true : false
		
		if @iphone_user_agent
			session[:iphone_format] ||= 'iphone'
			session[:iphone_format] = params[:iphone_format] if params[:iphone_format]
			request.format = :iphone if session[:iphone_format] == 'iphone'
		end
	end
	protected     :layout_data
	before_filter :layout_data


    # Finds DiscussionViews for @discussion
    def find_discussion_views
        if @current_user && @discussions && @discussions.length > 0
            @discussion_views = DiscussionView.find(
                :all,
                :conditions => {:user_id => @current_user.id, :discussion_id => @discussions.map(&:id).uniq}
            )
        end
    end

    # Loads and authenticates @current_user from session. Will fail
    # if the password has been changed. This is a feature.
    def authenticate_session
        if session[:user_id] && session[:hashed_password]
            user = User.find(session[:user_id]) rescue nil
            if user && session[:hashed_password] == user.hashed_password && !user.banned? && user.activated?
                @current_user = user
                Discussion.work_safe_urls = user.work_safe_urls?
                Category.work_safe_urls   = user.work_safe_urls?
            end
        end
    end
    protected     :authenticate_session
    before_filter :authenticate_session
    

    # Deauthenticate @current_user
    def deauthenticate!
        @current_user = nil
        store_session_authentication
    end
    protected :deauthenticate!
    

    # Stores authentication credentials in the session.
    def store_session_authentication
        if @current_user
            session[:user_id]         = @current_user.id
            session[:hashed_password] = @current_user.hashed_password
            session[:ips] ||= []
            session[:ips] << request.env['REMOTE_ADDR'] unless session[:ips].include?(request.env['REMOTE_ADDR'])
            # No need to update this on every request
            if !@current_user.last_active || @current_user.last_active < 10.minutes.ago
                @current_user.update_attribute(:last_active, Time.now)
            end
        else
            session[:user_id]         = nil
            session[:hashed_password] = nil
            session[:ips]             = nil
        end
    end
    protected    :store_session_authentication
    after_filter :store_session_authentication


    # Shortcut for setting up the authentication filter
    def self.requires_authentication(*args)
		append_before_filter(args){ |controller| controller.require_authenticated }
    end

    # Redirect to login page unless @current_user is active. The IP is verified to avoid session hijacking.
    def require_authenticated
        unless @current_user && session[:ips] && session[:ips].include?(request.env['REMOTE_ADDR'])
            #flash[:notice] = 'You must be logged in to to that.'
            redirect_to login_users_url and return
        end
    end
    
    def require_admin_or_user(user, options={})
        options[:redirect] ||= discussions_path
        options[:notice] ||= "You don't have permission to do that!"
        unless @current_user == user || @current_user.admin?
            flash[:notice] = options[:notice]
            redirect_to options[:redirect] and return
        end
    end

end
