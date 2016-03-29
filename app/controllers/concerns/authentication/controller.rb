# encoding: utf-8

module Authentication
  module Controller
    extend ActiveSupport::Concern
    include ActionView::Helpers::DateHelper
    include CurrentUserHelper

    included do
      before_action :load_session_user
      before_action :handle_temporary_ban
      before_action :handle_permanent_ban
      before_action :verify_activated_account
      after_action :cleanup_temporary_ban
      after_action :update_last_active
      after_action :store_session_authentication
    end

    protected

    # Verifies the current_user. The user is considered verified if one or more
    # criteria are met. If not, a redirect is performed.
    #
    # Criteria:
    #
    #  :user       - Checks that current_user matches the given user or :any
    #  :admin      - Checks that current_user is an admin
    #  :moderator  - Checks that current_user is a moderator
    #  :user_admin - Checks that current_user is a user admin
    #
    # Other options:
    #
    #  :notice   - Notice to display if verification fails
    #  :redirect - URL to redirect to if verification fails
    #
    # Examples:
    #
    #  # Require any user
    #  verify_user(
    #    user: :any,
    #    redirect: login_users_url,
    #    notice: 'You must be logged in!'
    #  )
    #
    #  # Only accessible by a moderator
    #  verify_user(moderator: true, notice: 'You must be a moderator!')
    #
    #  # Only accessible by a user admin or the user who owns the invite
    #  verify_user(user: @invite.user, user_admin: true)
    #
    def verify_user(options = {})
      options = default_verify_user_options(options)

      if current_user?
        verified = verify_current_user(options)
        verified ||= verify_current_user_flags(options)
      else
        verified = false
      end

      handle_unverified_user(options) unless verified
      verified
    end

    def verify_current_user(options = {})
      if options[:user]
        options[:user] == :any || options[:user] == current_user
      else
        false
      end
    end

    def verify_current_user_flags(options = {})
      [:admin, :moderator, :user_admin].each do |flag|
        return true if options[flag] && current_user.send("#{flag}?".to_sym)
      end
      false
    end

    def default_verify_user_options(options = {})
      options[:redirect] ||= discussions_url
      options[:notice] ||= "You don't have permission to do that!"
      options[:api_notice] ||= options[:notice]
      options
    end

    def handle_unverified_user(options)
      respond_to do |format|
        format.any(:html, :mobile) do
          flash[:notice] = options[:notice]
          redirect_to options[:redirect]
        end
        format.json { render json: options[:api_notice], status: 401 }
        format.xml { render xml: options[:api_notice], status: 401 }
      end
    end

    def require_user_account
      verify_user(
        user: :any,
        redirect: login_users_url,
        notice: "You must be logged in to do that",
        api_notice: "Authorization required"
      )
    end

    def load_session_user
      if session[:user_id] && session[:persistence_token] && !current_user?
        user = User.where(id: session[:user_id]).first
        if user && user.persistence_token == session[:persistence_token]
          @current_user = user
        end
      end
    end

    def ban_duration
      distance_of_time_in_words(Time.zone.now, current_user.banned_until)
    end

    def handle_temporary_ban
      if current_user? && current_user.temporary_banned?
        logger.info(
          "Authentication failed for user:#{current_user.id} " \
            "(#{current_user.username}) - temporary ban"
        )
        flash[:notice] = "You have been banned for #{ban_duration}!"
        deauthenticate!
      end
    end

    def handle_permanent_ban
      if current_user && current_user.banned?
        logger.info(
          "Authentication failed for user:#{current_user.id} " \
            "(#{current_user.username}) - permanent ban"
        )
        flash[:notice] = "You have been banned!"
        deauthenticate!
      end
    end

    def verify_activated_account
      if current_user?
        logger.info(
          "Authenticated as user:#{current_user.id} " \
            "(#{current_user.username})"
        )
      end
    end

    def deauthenticate!
      @current_user = nil
    end

    def cleanup_temporary_ban
      if current_user? &&
         current_user.banned_until? &&
         !current_user.temporary_banned?
        current_user.update_attributes(banned_until: nil)
      end
    end

    def update_last_active
      current_user.mark_active! if current_user?
    end

    def store_session_authentication
      if current_user
        session[:user_id] = current_user.id
        session[:persistence_token] = current_user.persistence_token
      else
        session[:user_id] = nil
        session[:persistence_token] = nil
      end
    end
  end
end
