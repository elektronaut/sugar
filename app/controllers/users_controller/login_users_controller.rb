class UsersController < ApplicationController
  module LoginUsersController
    extend ActiveSupport::Concern

    def login
    end

    def authenticate
      if @current_user = User.find_and_authenticate_with_password(params[:username], params[:password])
        store_session_authentication
        redirect_to discussions_url and return
      else
        flash[:notice] ||= "<strong>Oops!</strong> That’s not a valid username or password."
        redirect_to login_users_url
      end
    end

    def password_reset
    end

    def deliver_password
      @user = User.find_by_email(params[:email])
      if @user && @user.activated? && !@user.banned?
        @user.generate_new_password!
        Mailer.password_reminder(@user, login_users_path(:only_path => false)).deliver
        @user.save
        flash[:notice] = "A new password has been mailed to you"
        redirect_to login_users_url
      else
        flash[:notice] = "Could not reset your password. Did you provide the right email?"
        redirect_to password_reset_users_url
      end
    end

    def logout
      deauthenticate!
      flash[:notice] = "You have been logged out."
      redirect_to Sugar.public_browsing? ? discussions_url : login_users_url
    end

  end
end