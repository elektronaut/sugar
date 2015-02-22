class UsersController < ApplicationController
  module LoginUsersController
    extend ActiveSupport::Concern

    included do
      before_action :detect_admin_signup,        only: [:login]
      before_action :check_if_already_logged_in, only: [:login, :authenticate]
    end

    def login
    end

    def authenticate
      if set_current_user(
        User.find_and_authenticate_with_password(
          params[:username],
          params[:password]
        )
      )
        redirect_to discussions_url
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
      unless User.any?
        redirect_to new_user_path
        return
      end
    end

    def check_if_already_logged_in
      if current_user?
        redirect_to discussions_url
        return
      end
    end
  end
end
