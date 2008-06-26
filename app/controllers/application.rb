class ApplicationController < ActionController::Base

    helper :all # include all helpers, all the time

    # See ActionController::RequestForgeryProtection for details
    # Uncomment the :secret if you're not using the cookie session store
    protect_from_forgery # :secret => '21e3d7f3d3c39ae82439f2f9108fc36b'
    filter_parameter_logging :password

    layout 'default'

    # Misc. variables for the layout
    def layout_data
        @site_name = 'BUTT3RSCOTCH'
    end
    protected     :layout_data
    before_filter :layout_data

    # Loads and authenticates @current_user from session. Will fail if password
    # has been changed, this is a feature.
    def authenticate_session
        if session[:user_id] && session[:hashed_password]
            user = User.find(session[:user_id]) rescue nil
            if user && session[:hashed_password] == user.hashed_password && !user.banned? && user.activated?
                @current_user = user
            end
        end
    end
    protected     :authenticate_session
    before_filter :authenticate_session
    

    # Stores authentication credentials in the session.
    def store_session_authentication
        if @current_user
            session[:user_id]        = @current_user.id
            session[:hashed_password] = @current_user.hashed_password
            # No need to update this on every request
            if @current_user.last_active < 10.minutes.ago
                @current_user.update_attribute(:last_active, Time.now)
            end
        else
            session[:user_id]        = nil
            session[:hashed_password] = nil
        end
    end
    protected    :store_session_authentication
    after_filter :store_session_authentication


    # Shortcut for setting up the authentication filter
    def self.requires_authentication(*args)
		append_before_filter(args){ |controller| controller.require_authenticated }
    end

    # Redirect to login page unless @current_user is active.
    def require_authenticated
        unless @current_user
            flash[:notice] = 'You must be logged in to to that.'
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
