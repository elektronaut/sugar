require 'digest/md5'

class ApplicationController < ActionController::Base

	layout 'default'
	helper :all
	
	include ActionView::Helpers::DateHelper

	# See ActionController::RequestForgeryProtection for details
	# Uncomment the :secret if you're not using the cookie session store
	protect_from_forgery # :secret => '21e3d7f3d3c39ae82439f2f9108fc36b'

	# Filters
	before_filter :authenticate_session
	before_filter :facebook_authenticate
	before_filter :detect_mobile
	before_filter :set_time_zone
	before_filter :set_section
	after_filter  :store_session_authentication

	class << self

		# Requires a user unless public browsing is on
		def requires_authentication(*args)
			self.send(:before_filter, *args) do |controller|
				unless Sugar.config(:public_browsing)
					controller.send(:require_user_account) 
				end
			end
		end

		# Requires a logged in user
		def requires_user(*args)
			self.send(:before_filter, *args) do |controller|
				controller.send(:require_user_account) 
			end
		end

		# Requires a logged in admin
		def requires_admin(*args)
			self.send(:before_filter, *args) do |controller|
				controller.send(:verify_user, :admin => true)
			end
		end

		# Requires a logged in moderator
		def requires_moderator(*args)
			self.send(:before_filter, *args) do |controller|
				controller.send(:verify_user, :moderator => true)
			end
		end

		# Requires a logged in user admin
		def requires_user_admin(*args)
			self.send(:before_filter, *args) do |controller|
				controller.send(:verify_user, :user_admin => true)
			end
		end

	end
	
	protected

		# Verifies the @current_user. The user is considered verified if one or more
		# criteria are met. If not, a redirect is performed. 
		#
		# Criteria:
		#
		#  :user       - Checks that @current_user matches the given user or :any
		#  :admin      - Checks that @current_user is an admin
		#  :moderator  - Checks that @current_user is a moderator
		#  :user_admin - Checks that @current_user is a user admin
		#
		# Other options:
		#
		#  :notice   - Notice to display if verification fails
		#  :redirect - URL to redirect to if verification fails
		#
		# Examples:
		#
		#  # Require any user
		#  verify_user(:user => :any, :redirect => login_users_url, :notice => 'You must be logged in!')
		#
		#  # Only accessible by a moderator
		#  verify_user(:moderator => true, :notice => 'You must be a moderator!')
		#
		#  # Only accessible by a user admin or the user who owns the invite
		#  verify_user(:user => @invite.user, :user_admin => true)
		#
		def verify_user(options={})
			options[:redirect]   ||= discussions_url
			options[:notice]     ||= "You don't have permission to do that!"
			options[:api_notice] ||= options[:notice]

			verified = false
			if @current_user && @current_user.activated?
				verified ||= options[:user] == :any          if options[:user]
				verified ||= options[:user] == @current_user if options[:user]
				verified ||= @current_user.admin?            if options[:admin]
				verified ||= @current_user.moderator?        if options[:moderator]
				verified ||= @current_user.user_admin?       if options[:user_admin]
			end

			unless verified
				respond_to do |format|
					format.any(:html, :mobile) do
						flash[:notice] = options[:notice]
						redirect_to options[:redirect]
					end
					format.json { render :json => options[:api_notice], :status => 401 }
					format.xml  { render :xml  => options[:api_notice], :status => 401 }
				end
			end
			return verified
		end
		
		# Requires a user account
		def require_user_account
			verify_user(
				:user       => :any, 
				:redirect   => login_users_url, 
				:notice     => 'You must be logged in to do that',
				:api_notice => 'Authorization required'
			)
		end

		# Renders an error
		def render_error(error, options={})
			options[:status] ||= error if error.kind_of?(Numeric)
			error_messages = {
				404 => 'Not found'
			}
			respond_to do |format|
				format.html   {options[:template] ||= "errors/#{error}"}
				format.mobile {options[:template] ||= "errors/#{error}"}
				format.xml    {options[:text] ||= error_messages[error]}
				format.json   {options[:text] ||= error_messages[error]}
			end
			render options
		end

		# Detects the mobile user agent string and sets <tt>request.format = :mobile</tt>.
		def detect_mobile
			@mobile_user_agent = (request.host =~ /^(iphone|m|mobile)\./ || (request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari|Android)/])) ? true : false
			if @mobile_user_agent
				session[:mobile_format] ||= 'mobile'
				session[:mobile_format] = params[:mobile_format] if params[:mobile_format]
				request.format = :mobile if session[:mobile_format] == 'mobile'
			end
		end
		
		# Sets <tt>@section</tt> to the current section.
		def set_section
			case self.class.to_s
			when 'UsersController'
				@section = :users
			when 'MessagesController'
				@section = :messages
			when 'InvitesController'
				@section = :invites
			else
				@section = :discussions
			end
		end
		
		# Set time zone for user
		def set_time_zone
			Time.zone = @current_user.time_zone if @current_user && @current_user.time_zone
		end

		# Finds DiscussionViews for @discussion.
		def load_views_for(discussions)
			if @current_user && discussions && discussions.length > 0
				@discussion_views = DiscussionView.find(
					:all,
					:conditions => {:user_id => @current_user.id, :discussion_id => discussions.map(&:id).uniq}
				)
			end
		end

		# Gets the OpenID consumer, creates it if necessary.
		def openid_consumer
			require 'openid/store/filesystem'
			@openid_consumer ||= OpenID::Consumer.new(session,      
				OpenID::Store::Filesystem.new("#{Rails.root.to_s}/tmp/openid"))
	    end
	
		# Loads and authenticates @current_user from session. Will fail
		# if the password has been changed. This is a feature.
		def authenticate_session
			if session[:user_id] && session[:hashed_password]
				user = User.find(session[:user_id]) rescue nil
				if user && session[:hashed_password] == user.hashed_password && !user.banned? && user.activated?
					if user.temporary_banned?
						flash[:notice] = "You have been banned for #{distance_of_time_in_words(Time.now - user.banned_until)}!"
					else
						@current_user = user
						Discussion.work_safe_urls = user.work_safe_urls?
						Category.work_safe_urls   = user.work_safe_urls?
					end
				end
			end
		end

		# Facebook authentication
		def facebook_authenticate
			if Sugar.config(:facebook_app_id) && request.cookies["fbs_#{Sugar.config(:facebook_app_id)}"]

				# Parse the facebook session
				facebook_session = request.cookies["fbs_#{Sugar.config(:facebook_app_id)}"].gsub(/(^\"|\"$)/, '')
				facebook_session = CGI::parse(facebook_session).inject(Hash.new) do |memo, val|
					memo[val.first] = val.last.first
					memo
				end
				facebook_session.symbolize_keys!
				
				# Verify the payload
				payload = facebook_session.keys.sort.reject{|k| k == :sig}.map{|k| "#{k.to_s}=#{facebook_session[k]}"}.join
				expected_sig = Digest::MD5.hexdigest(payload + Sugar.config(:facebook_api_secret))
				if facebook_session[:sig] && !facebook_session[:sig].empty? && facebook_session[:sig] == expected_sig
					@facebook_session = facebook_session
				else
					@facebook_session = false
				end
			end
		end

		# Deauthenticates the current user
		def deauthenticate!
			@current_user = nil
			store_session_authentication
		end

		# Stores authentication credentials in the session.
		def store_session_authentication
			if @current_user
				session[:user_id]         = @current_user.id
				session[:hashed_password] = @current_user.hashed_password

				# No need to update this on every request
				if !@current_user.last_active || @current_user.last_active < 10.minutes.ago
					@current_user.update_attribute(:last_active, Time.now)
				end

				# Clean up banned_until
				if @current_user.banned_until? && !@current_user.temporary_banned?
					@current_user.update_attribute(:banned_until, nil)
				end
			else
				session[:user_id]         = nil
				session[:hashed_password] = nil
				session[:ips]             = nil
			end
		end
		
end
