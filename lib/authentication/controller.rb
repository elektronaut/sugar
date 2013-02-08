# encoding: utf-8

module Authentication
  module Controller

    extend  ActiveSupport::Concern
    include ActionView::Helpers::DateHelper

    included do
      before_filter :load_session_user
      before_filter :handle_temporary_ban
      before_filter :handle_permanent_ban
      before_filter :verify_activated_account
      after_filter :cleanup_temporary_ban
      after_filter :update_last_active
      after_filter :cleanup_authenticated_openid_url
      after_filter :store_session_authentication
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
        options = default_verify_user_options(options)

        verified = false
        if @current_user && @current_user.activated?
          verified ||= options[:user] == :any          if options[:user]
          verified ||= options[:user] == @current_user if options[:user]
          verified ||= @current_user.admin?            if options[:admin]
          verified ||= @current_user.moderator?        if options[:moderator]
          verified ||= @current_user.user_admin?       if options[:user_admin]
        end

        handle_unverified_user(options) unless verified
        return verified
      end

      # Default options for verify user.
      def default_verify_user_options(options={})
        options[:redirect]   ||= discussions_url
        options[:notice]     ||= "You don't have permission to do that!"
        options[:api_notice] ||= options[:notice]
        options
      end

      # Handle an unverified user.
      def handle_unverified_user(options)
        respond_to do |format|
          format.any(:html, :mobile) do
            flash[:notice] = options[:notice]
            redirect_to options[:redirect]
          end
          format.json { render :json => options[:api_notice], :status => 401 }
          format.xml  { render :xml  => options[:api_notice], :status => 401 }
        end
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

      # Tries to set @current_user based on session data
      def load_session_user
        if session[:user_id] && session[:persistence_token]
          begin
            user = User.find(session[:user_id])
            @current_user ||= user if user.persistence_token == session[:persistence_token]
          rescue ActiveRecord::RecordNotFound
            # No need to do anything if the record does not exist
          end
        end
      end

      # Handles temporary bans.
      def handle_temporary_ban
        if @current_user && @current_user.temporary_banned?
          logger.info "Authentication failed for user:#{@current_user.id} (#{@current_user.username}) - temporary ban"
          flash[:notice] = "You have been banned for #{distance_of_time_in_words(Time.now, @current_user.banned_until)}!"
          @current_user = nil
        end
      end

      # Handles permanent bans.
      def handle_permanent_ban
        if @current_user && @current_user.banned?
          logger.info "Authentication failed for user:#{@current_user.id} (#{@current_user.username}) - permanent ban"
          flash[:notice] = "You have been banned!"
          @current_user = nil
        end
      end

      # Verifies that the account is activated
      def verify_activated_account
        if @current_user
          if @current_user.activated?
            logger.info "Authenticated as user:#{@current_user.id} (#{@current_user.username})"
          else
            logger.info "Authentication failed for user:#{@current_user.id} (#{@current_user.username}) - not activated"
            @current_user = nil
          end
        end
      end

      # Deauthenticates the current user.
      def deauthenticate!
        @current_user = nil
        store_session_authentication
      end

      # Cleans up temporary bans.
      def cleanup_temporary_ban
        if @current_user && @current_user.banned_until? && !@current_user.temporary_banned?
          @current_user.update_attributes(:banned_until => nil)
        end
      end

      # Deletes session[:authenticated_openid_url] if user is authenticated
      def cleanup_authenticated_openid_url
        if @current_user && session[:authenticated_openid_url]
          session.delete(:authenticated_openid_url)
        end
      end

      # Updates the last_active timestamp
      def update_last_active
        if @current_user
          @current_user.mark_active!
        end
      end

      # Stores authentication credentials in the session.
      def store_session_authentication
        if @current_user
          session[:user_id]           = @current_user.id
          session[:persistence_token] = @current_user.persistence_token
        else
          session[:user_id]           = nil
          session[:persistence_token] = nil
        end
      end

  end
end
