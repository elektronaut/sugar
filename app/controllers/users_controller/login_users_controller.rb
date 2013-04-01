class UsersController < ApplicationController
  module LoginUsersController
    extend ActiveSupport::Concern

    included do
      before_filter :detect_admin_signup,        :only => [:login]
      before_filter :check_if_already_logged_in, :only => [:login, :authenticate]
    end

    def login
    end

    def authenticate
      if @current_user = User.find_and_authenticate_with_password(params[:username], params[:password])
        store_session_authentication
        redirect_to discussions_url and return
      else
        flash[:notice] ||= "That's not a valid username or password."
        redirect_to login_users_url
      end
    end

    def logout
      deauthenticate!
      flash[:notice] = "You have been logged out."
      redirect_to Sugar.public_browsing? ? discussions_url : login_users_url
    end

    private

    def detect_admin_signup
      redirect_to new_user_path and return unless User.any?
    end

    def check_if_already_logged_in
      redirect_to discussions_url and return if @current_user
    end

  end
end