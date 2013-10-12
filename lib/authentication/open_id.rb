# encoding: utf-8

module Authentication
  module OpenID

    extend ActiveSupport::Concern

    included do
      before_filter :load_openid_user
    end

    protected

      # Tries to set current_user based on session[:authenticated_openid_url]
      def load_openid_user
        if session[:authenticated_openid_url] && !current_user?
          set_current_user(User.find_by_openid_url(session[:authenticated_openid_url]))
        end
      end

      # Returns an OpenID consumer, creating it if necessary
      def openid_consumer
        require 'openid/store/filesystem'
        @openid_consumer ||= ::OpenID::Consumer.new(session,
          ::OpenID::Store::Filesystem.new("#{Rails.root.to_s}/tmp/openid"))
      end

      # Starts an OpenID session
      def start_openid_session(identity_url, options={})
        options[:success] ||= root_path
        options[:fail]    ||= login_users_path
        session[:openid_redirect_success] = options[:success]
        session[:openid_redirect_fail]    = options[:fail]

        begin
          response = openid_consumer.begin(identity_url)
        rescue ::OpenID::DiscoveryFailure
          response = false
        end

        if response
          perform_openid_authentication(response, options)
          return true
        else
          return false
        end
      end

      # Performs the OpenID authentication
      def perform_openid_authentication(response, options={})
        options = {
          :url       => complete_openid_url,
          :base_url  => root_url,
          :immediate => false
        }.merge(options)
        redirect_to response.redirect_url(options[:base_url], options[:url], options[:immediate])
      end

  end
end
