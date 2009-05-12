class UsersController < ApplicationController

    requires_authentication :except => [:login, :complete_openid_login, :logout, :forgot_password]
    
    def load_user
        @user = User.find_by_username(params[:id]) || User.find(params[:id]) rescue nil
        unless @user
            flash[:notice] = "User not found!"
            redirect_to users_url and return
        end
    end
    protected     :load_user
    before_filter :load_user, :only => [:show, :edit, :update, :destroy, :participated, :discussions, :posts]
    
    def index
        @users  = User.find(:all, :order => 'username ASC', :conditions => 'activated = 1 AND banned = 0')
    end

    def banned
        @users  = User.find(:all, :order => 'username ASC', :conditions => 'banned = 1')
    end

	def recently_joined
		@users = User.find_new
	end

	def online
		@users = User.find_online
	end
	
	def admins
        @users  = User.find_admins
	end
    
    def xboxlive
        @users = XboxInfo.valid_users
    end

	def twitter
		@users = User.find_twitter_users
	end
	
	def top_posters
		@users = User.find_top_posters(:limit => 50)
	end
    
    def show
		respond_to do |format|
			format.html do
				@posts = @user.paginated_posts(:page => params[:page], :trusted => @current_user.trusted?, :limit => 15)
			end
			format.iphone {}
		end
    end
    
    def discussions
        @discussions = @user.paginated_discussions(:page => params[:page], :trusted => @current_user.trusted?)
        find_discussion_views
    end
    
	def participated
		@section = :participated if @user == @current_user
		@discussions = @user.participated_discussions(:page => params[:page], :trusted => @current_user.trusted?)
		find_discussion_views
	end
	
	def posts
		@posts = @user.paginated_posts(:page => params[:page], :trusted => @current_user.trusted?)
	end

    def new
        unless @current_user.user_admin?
            flash[:notice] = "You don't have permission to do that!"
            redirect_to users_url and return
        end
        @user = @current_user.invitees.new
        @user.activated = true
        @user.generate_password!
    end

    def create
        unless @current_user.user_admin?
            flash[:notice] = "You don't have permission to do that!"
            redirect_to users_url and return
        end
        params[:user][:confirm_password] = params[:user][:password]
        @user = User.create(params[:user])
        if @user.valid?
            Notifications.deliver_new_user(@user, login_users_path(:only_path => false), params[:message])
            flash[:notice] = "#{@user.username} has been invited by email"
            redirect_to users_url and return
        else
            flash.now[:notice] = "Invalid user, please fill in all required fields."
            render :action => :new
        end
    end

    def edit
        # TODO: refactor to .editable_by?
        require_admin_or_user(@user, :redirect => user_url(@user))
    end
    
    def update
        require_admin_or_user(@user, :redirect => user_url(@user))
        attributes = @current_user.admin? ? params[:user] : User.safe_attributes(params[:user])

        @user.update_attributes(attributes)
        if @user.valid?
            if @user == @current_user
                # Make sure the session data is updated
                @current_user.reload
                store_session_authentication
            end
            flash[:notice] = "Your changes were saved!"
            redirect_to user_url(:id => @user.username)
        else
            flash.now[:notice] = "There was an error saving your changes"
            render :action => :edit
        end
    end

	def complete_openid_login
		response_params = params
		response_params.delete(:controller)
		response_params.delete(:action)
		response = openid_consumer.complete(response_params, complete_openid_login_users_url)

		case response
		when OpenID::Consumer::SetupNeededResponse
			setup_url = response.instance_eval{ @setup_url } rescue nil
			if setup_url
				redirect_to setup_url and return
			else
				setup_response = openid_consumer.begin(response.identity_url) rescue nil
				if setup_response
					redirect_to setup_response.redirect_url(root_url, complete_openid_login_users_url) and return
				end
			end
		when OpenID::Consumer::SuccessResponse
			user = User.first(:conditions => {:openid_url => response.identity_url})
			if user
				if user.activated? && !user.banned?
                    @current_user = user
                    store_session_authentication
					redirect_to discussions_url and return
				else
					flash[:notice] = "You're not allowed to log in!"
				end
			else
				flash[:notice] = 'There are no users registered with that identity URL.'
			end
		when OpenID::Consumer::FailureResponse
			raise "fail"
		end
		
		flash[:notice] ||= 'OpenID login failed.'
		redirect_to login_users_url
	end
    
    def login
        redirect_to discussions_url and return if @current_user
        if request.post?
			if params[:username] && params[:password] && !params[:username].blank? && !params[:password].blank?
                user = User.find_by_username(params[:username])
                if user && user.valid_password?(params[:password])
                    @current_user = user
                    store_session_authentication
                    redirect_to discussions_url and return
                end
			elsif params[:openid_url] && !params[:openid_url].blank?
				openid_url = params[:openid_url]
				response = openid_consumer.begin(openid_url) rescue nil
				if response
					redirect_to response.redirect_url(root_url, complete_openid_login_users_url, true) and return
				else
					flash.now[:notice] = "Couldn't find an OpenID for that URL."
				end
			end
            flash.now[:notice] ||= "<strong>Oops!</strong> That’s not a valid username or password." unless @current_user
        end
        render :layout => 'login'
    end
    
    def forgot_password
        @user = User.find_by_email(params[:email])
        if @user
            if @user.activated? && !@user.banned?
                @user.generate_password!
                Notifications.deliver_password_reminder(@user, login_users_path(:only_path => false))
                @user.save
                flash[:notice] = "A new password has been mailed to you"
            else
                flash[:notice] = "Your account isn't active, you can't do that yet"
            end
        else
            flash[:notice] = "<strong>Oops!</strong> Couldn't find your email address."
        end
        redirect_to login_users_url
    end
    
    def logout
        deauthenticate!
        redirect_to login_users_url
    end

end
