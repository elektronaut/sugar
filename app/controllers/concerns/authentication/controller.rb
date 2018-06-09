# encoding: utf-8

module Authentication
  module Controller
    extend ActiveSupport::Concern
    include ActionView::Helpers::DateHelper
    include CurrentUserHelper

    included do
      before_action :load_session_user,
                    :verify_active_account
      after_action :update_last_active,
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
      return nil unless current_user.temporary_banned?
      distance_of_time_in_words(Time.zone.now, current_user.banned_until)
    end

    def verify_active_account
      return unless current_user?
      current_user.check_status!
      if current_user.active?
        logger.info("Authenticated as user:#{current_user.id} " \
                    "(#{current_user.username})")
      else
        logger.info("Authentication failed for user:#{current_user.id} " \
                    "(#{current_user.username}) - #{current_user.status}")
        flash[:notice] = t("authentication.notice.#{current_user.status}",
                           duration: ban_duration)
        deauthenticate!
      end
    end

    def deauthenticate!
      @current_user = nil
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
