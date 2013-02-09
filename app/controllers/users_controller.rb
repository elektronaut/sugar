# encoding: utf-8

require 'open-uri'

class UsersController < ApplicationController
  include UsersListController, OpenidUserController, LoginUsersController

  requires_authentication :except => [:login, :authenticate, :logout, :password_reset, :deliver_password, :new, :create]
  requires_user           :only   => [:edit, :update, :update_openid]
  requires_user_admin     :only   => [:grant_invite, :revoke_invites]

  before_filter :load_user,
                :only => [
                  :show, :edit,
                  :update, :destroy,
                  :participated, :discussions,
                  :posts, :update_openid,
                  :grant_invite, :revoke_invites,
                  :stats
                ]

  before_filter :detect_admin_signup,        :only => [:login]
  before_filter :detect_edit_page,           :only => [:edit, :update]
  before_filter :check_if_already_logged_in, :only => [:login, :authenticate]
  before_filter :find_invite,                :only => [:new, :create]
  before_filter :check_for_expired_invite,   :only => [:new, :create]
  before_filter :check_for_signups_allowed,  :only => [:new, :create]
  before_filter :verify_editable,            :only => [:edit, :update, :update_openid]

  respond_to :html, :mobile, :xml, :json

  private

    def load_user
      begin
        @user = User.find_by_username(params[:id]) || User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        @user = nil
      end
      unless @user
        flash[:notice] = "User not found!"
        redirect_to users_url and return
      end
    end

    def detect_edit_page
      pages = %w{admin info location services settings temporary_ban}
      @page = params[:page] if pages.include?(params[:page])
      @page ||= 'info'
    end

    def detect_admin_signup
      redirect_to new_user_path and return unless User.any?
    end

    def check_if_already_logged_in
      redirect_to discussions_url and return if @current_user
    end

    def find_invite
      if invite_token?
        @invite = Invite.find_by_token(invite_token)
      end
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

    def verify_editable
      return unless verify_user(:user => @user, :user_admin => true, :redirect => user_url(@user))
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

    def facebook_user_params
      session[:facebook_user_params] || {}
    end

    def allowed_params
      allowed = [
        :aim, :application, :avatar_url, :birthday, :description, :email,
        :facebook_uid, :flickr, :gamertag, :gtalk, :html_disabled, :instagram,
        :last_fm, :latitude, :location, :longitude, :mobile_stylesheet_url,
        :mobile_theme, :msn, :notify_on_message, :realname,
        :stylesheet_url, :theme, :time_zone, :twitter, :website,
        :password, :confirm_password
      ]
      if @current_user
        if @current_user.user_admin?
          allowed += [
            :username, :banned, :activated, :user_admin, :moderator,
            :trusted, :available_invites, :banned_until
          ]
        end
        if @current_user.admin?
          allowed += [:admin]
        end
      end
      allowed
    end

    def user_params
      params.require(:user).permit(*allowed_params)
    end

    def new_user_params
      params.require(:user).permit(:username, *allowed_params).merge(facebook_user_params)
    end

  public

    def show
      respond_with(@user) do |format|
        format.html do
          @posts = @user.paginated_posts(
            :page    => params[:page],
            :trusted => (@current_user && @current_user.trusted?),
            :limit   => 15
          )
        end
      end
    end

    def discussions
      @discussions = @user.paginated_discussions(
        :page    => params[:page],
        :trusted => @current_user.trusted?
      )
      load_views_for(@discussions)
    end

    def participated
      @section = :participated if @user == @current_user
      @discussions = @user.participated_discussions(
        :page    => params[:page],
        :trusted => @current_user.trusted?
      )
      load_views_for(@discussions)
    end

    def posts
      @posts = @user.paginated_posts(
        :page    => params[:page],
        :trusted => (@current_user && @current_user.trusted?)
      )
    end

    def stats
      @posts_per_week = Post.find_by_sql(
        "SELECT COUNT(*) AS post_count, YEAR(created_at) AS year, WEEK(created_at) AS week " +
        "FROM posts " +
        "WHERE user_id = #{@user.id} " +
        "GROUP BY YEAR(created_at), WEEK(created_at);"
      )
      @max_posts_per_week = @posts_per_week.map{|p| p.post_count.to_i}.max
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

    def edit
    end

    def update
      if @user.update_attributes(user_params)

        if @user == @current_user
          @current_user.reload
          store_session_authentication
        end

        unless initiate_openid_on_update
          flash[:notice] = "Your changes were saved!"
          redirect_to edit_user_page_url(:id => @user.username, :page => @page)
        end

      else
        flash.now[:notice] ||= "There were errors saving your changes"
        render :action => :edit
      end
    end

    def grant_invite
      @user.grant_invite!
      flash[:notice] = "#{@user.username} has been granted one invite."
      redirect_to user_url(:id => @user.username) and return
    end

    def revoke_invites
      @user.revoke_invite!(:all)
      flash[:notice] = "#{@user.username} has been revoked of all invites."
      redirect_to user_url(:id => @user.username) and return
    end

end
