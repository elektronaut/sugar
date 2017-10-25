# encoding: utf-8

module Authentication
  module Controller
    extend ActiveSupport::Concern
    include ActionView::Helpers::DateHelper
    include CurrentUserHelper

    included do
      before_action :load_session_user,
                    :handle_memorialized,
                    :handle_temporary_ban,
                    :handle_permanent_ban,
                    :verify_activated_account
      after_action :cleanup_temporary_ban,
                   :update_last_active,
                   :store_session_authentication
    end

    protected

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

    def handle_memorialized
      if current_user? && current_user.memorialized?
        logger.info(
          "Authentication failed for user:#{current_user.id} " \
          "(#{current_user.username}) - memorialized"
        )
        flash[:notice] = "This account has been memorialized and is " \
                         "inaccessible"
        deauthenticate!
      end
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
