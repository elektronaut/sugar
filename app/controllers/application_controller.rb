class ApplicationController < ActionController::Base

	if RAILS_ENV == 'profile'
		require 'ruby-prof'
		
		def profile_start
			RubyProf.measure_mode = RubyProf::WALL_TIME
			RubyProf.start
		end
		before_filter :profile_start
		
		def profile_end
			result = RubyProf.stop
			printer = RubyProf::FlatPrinter.new(result)
			printer.print(STDOUT, 0)
		end
		after_filter :profile_end
	end

	layout 'default'
	helper :all
	filter_parameter_logging :password, :drawing

	# See ActionController::RequestForgeryProtection for details
	# Uncomment the :secret if you're not using the cookie session store
	protect_from_forgery # :secret => '21e3d7f3d3c39ae82439f2f9108fc36b'

	# Filters
	before_filter :authenticate_session
	before_filter :detect_iphone
	before_filter :set_section
	after_filter  :store_session_authentication

	# Shortcut for setting up the authentication filter. Example:
	#   requires_authentication :except => [:login, :logout, :forgot_password]
	def self.requires_authentication(*args)
		append_before_filter(args){ |controller| controller.require_authenticated }
	end

	# Redirect to login page unless <tt>@current_user</tt> is activated. 
	# The IP is verified to avoid session hijacking.
	def require_authenticated
		unless @current_user #&& session[:ips] && session[:ips].include?(request.env['REMOTE_ADDR'])
			#flash[:notice] = 'You must be logged in to to that.'
			redirect_to login_users_url and return
		end
	end

	# Redirect to <tt>options[:redirect]</tt> (default: <tt>discussions_path</tt>)
	# unless <tt>@current_user</tt> is <tt>user</tt> or an admin.
	def require_admin_or_user(user, options={})
		options[:redirect] ||= discussions_path
		options[:notice] ||= "You don't have permission to do that!"
		unless @current_user == user || @current_user.admin?
			flash[:notice] = options[:notice]
			redirect_to options[:redirect] and return
		end
	end

	# Redirect to <tt>options[:redirect]</tt> (default: <tt>discussions_path</tt>)
	# unless <tt>@current_user</tt> is <tt>user</tt> or a user admin.
	def require_user_admin_or_user(user, options={})
		options[:redirect] ||= discussions_path
		options[:notice] ||= "You don't have permission to do that!"
		unless @current_user == user || @current_user.user_admin?
			flash[:notice] = options[:notice]
			redirect_to options[:redirect] and return
		end
	end

	protected

		# Detects the iPhone user agent string and sets <tt>request.format = :iphone</tt>.
		def detect_iphone
			@iphone_user_agent = (request.host =~ /^(iphone|m)\./ || (request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/])) ? true : false
			if @iphone_user_agent
				session[:iphone_format] ||= 'iphone'
				session[:iphone_format] = params[:iphone_format] if params[:iphone_format]
				request.format = :iphone if session[:iphone_format] == 'iphone'
			end
		end

		# Sets <tt>@section</tt> to the current section.
		def set_section
			case self.class.to_s
			when 'UsersController'
				@section = :users
			when 'CategoriesController'
				@section = :categories
			when 'MessagesController'
				@section = :messages
			when 'InvitesController'
				@section = :invites
			else
				@section = :discussions
			end
		end

		# Finds DiscussionViews for @discussion.
		def find_discussion_views
			if @current_user && @discussions && @discussions.length > 0
				@discussion_views = DiscussionView.find(
					:all,
					:conditions => {:user_id => @current_user.id, :discussion_id => @discussions.map(&:id).uniq}
				)
			end
		end

		# Gets the OpenID consumer, creates it if necessary.
		def openid_consumer
			require 'openid/store/filesystem'
			@openid_consumer ||= OpenID::Consumer.new(session,      
				OpenID::Store::Filesystem.new("#{RAILS_ROOT}/tmp/openid"))
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

		# Deauthenticates <tt>@current_user</tt>.
		def deauthenticate!
			@current_user = nil
			store_session_authentication
		end

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
		
end
