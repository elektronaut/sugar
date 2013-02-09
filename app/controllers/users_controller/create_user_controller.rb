class UsersController < ApplicationController
  module CreateUserController
    extend ActiveSupport::Concern

    included do
      before_filter :find_invite,               :only => [:new, :create]
      before_filter :check_for_expired_invite,  :only => [:new, :create]
      before_filter :check_for_signups_allowed, :only => [:new, :create]
    end

    def new
      if @invite
        session[:invite_token] = @invite.token
        @user = @invite.user.invitees.new(new_user_params)
        @user.email = @invite.email
      else
        @user = User.new(new_user_params)
      end
    end

    def create
      @user = User.new(new_user_params)
      @user.invite = @invite # This can be nil
      @user.activated = true unless Sugar.config(:signup_approval_required)

      if @user.save
        finalize_successful_signup
        unless initiate_openid_on_create
          redirect_to user_url(:id => @user.username)
        end
      else
        flash.now[:notice] = "Could not create your account, please fill in all required fields."
        render :action => :new
      end
    end

    private

    def find_invite
      if invite_token?
        @invite = Invite.find_by_token(invite_token)
      end
    end

    def invite_token
      params[:token] || session[:invite_token]
    end

    def invite_token?
      invite_token ? true : false
    end

    def finalize_successful_signup
      if @user.email?
        Mailer.new_user(@user, login_users_path(:only_path => false)).deliver
      end
      session.delete(:facebook_user_params)
      session.delete(:invite_token)
      @current_user = @user
      store_session_authentication
    end

    def check_for_expired_invite
      if @invite && @invite.expired?
        session.delete(:invite_token)
        flash[:notice] = "Your invite has expired"
        redirect_to login_users_url and return
      end
    end

    def check_for_signups_allowed
      if !Sugar.config(:signups_allowed) && User.any? && !@invite
        flash[:notice] = "Signups are not allowed"
        redirect_to login_users_url and return
      end
    end

    def facebook_user_params
      session[:facebook_user_params] || {}
    end

  end
end