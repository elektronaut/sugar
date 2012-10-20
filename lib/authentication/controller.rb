# encoding: utf-8

module Authentication
  module Controller

    extend  ActiveSupport::Concern
    include ActionView::Helpers::DateHelper

    included do
      before_filter :load_session_user
      before_filter :finalize_authentication
      after_filter  :store_session_authentication
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

      # Tries to set @current_user based on session data
      def load_session_user
        if session[:user_id] && session[:hashed_password]
          begin
            user = User.find(session[:user_id])
            @current_user ||= user if user.hashed_password == session[:hashed_password]
          rescue ActiveRecord::RecordNotFound
            # No need to do anything if the record does not exist
          end
        end
      end

      # Finalizes authentication, checks that the @current_user is activated and not banned
      def finalize_authentication
        if @current_user
          logger.info "Authenticated as user:#{@current_user.id} (#{@current_user.username})"
          if !@current_user.activated? || @current_user.banned? || @current_user.temporary_banned?
            if @current_user.temporary_banned?
              logging.info "Authorization failed, temporary ban"
              flash[:notice] = "You have been banned for #{distance_of_time_in_words(Time.now, @current_user.banned_until)}!"
            elsif @current_user.banned?
              logging.info "Authorization failed, permanent ban"
              flash[:notice] = "You have been banned!"
            end
            @current_user = nil
          end
        end
      end

      # Deauthenticates the current user
      def deauthenticate!
        @current_user = nil
        session[:authenticated_openid_url] = nil
        store_session_authentication
      end

      # Stores authentication credentials in the session.
      def store_session_authentication
        if @current_user
          session[:user_id]         = @current_user.id
          session[:hashed_password] = @current_user.hashed_password

          # Clean up banned_until
          if @current_user.banned_until? && !@current_user.temporary_banned?
            @current_user.update_attribute(:banned_until, nil)
          end

          # No need to update this on every request
          if !@current_user.last_active || @current_user.last_active < 10.minutes.ago
            @current_user.update_column(:last_active, Time.now) unless @current_user.temporary_banned?
          end
        else
          session[:user_id]         = nil
          session[:hashed_password] = nil
        end
      end

  end
end
