# encoding: utf-8

require 'open-uri'

class UsersController < ApplicationController

  requires_authentication :except => [:login, :logout, :password_reset, :new, :create]
  requires_user           :only   => [:edit, :update, :grant_invite, :revoke_invites]

  before_filter :load_user,
                :only => [
                  :show, :edit,
                  :update, :destroy,
                  :participated, :discussions,
                  :posts, :update_openid,
                  :grant_invite, :revoke_invites,
                  :stats
                ]

  before_filter :detect_admin_signup, :only => [:login, :new, :create]
  before_filter :detect_edit_page,    :only => [:edit, :update]

  respond_to :html, :mobile, :xml, :json

  protected

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

    def detect_admin_signup
      @admin_signup = true if User.count(:all) == 0
    end

    def detect_edit_page
      pages = %w{admin info location services settings temporary_ban}
      @page = params[:page] if pages.include?(params[:page])
      @page ||= 'info'
    end

  public

    def index
      @users = User.active
      respond_with(@users) do |format|
        format.mobile {
          @online_users = @users.select{|u| u.online?}
        }
      end
    end

    def banned
      @users  = User.banned.by_username
      respond_with(@users)
    end

    def recently_joined
      @users = User.recently_joined.limit(25)
      respond_with(@users)
    end

    def online
      @users = User.online.by_username
      respond_with(@users)
    end

    def admins
      @users  = User.admins.by_username
      respond_with(@users)
    end

    def xboxlive
      @users = User.xbox_users.by_username
      respond_with(@users)
    end

    def social
      @users = User.social.by_username
      respond_with(@users)
    end

    def top_posters
      @users = User.top_posters.limit(50)
      respond_with(@users)
    end

    def map
    end

    def trusted
      unless @current_user && @current_user.trusted?
        flash[:notice] = "You need to be trusted to view this page!"
      end
      @users = User.trusted.by_username
      respond_with(@users)
    end

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
      user_params = session[:user_params] || {}

      # New by invitation
      if invite_token = (params[:token] || session[:invite_token])
        @invite = Invite.first(:conditions => {:token => invite_token})
        if @invite && !@invite.expired?
          session[:invite_token] = @invite.token
          @user = @invite.user.invitees.new(user_params)
          @user.email = @invite.email
        else
          flash[:notice] = "That's not a valid invite!"
          redirect_to login_users_url and return
        end
        # Signups allowed
      elsif Sugar.config(:signups_allowed) || @admin_signup
        @user = User.new(user_params)
      else
        flash[:notice] = "Signups are not allowed!"
        redirect_to login_users_url and return
      end
    end

    def create
      if params[:token]
        @invite = Invite.first(:conditions => {:token => params[:token]})
        @invite = nil if @invite.expired?
      end

      unless Sugar.config(:signups_allowed) || @invite || @admin_signup
        flash[:notice] = "Signups are not allowed!"
        redirect_to login_users_url and return
      end

      # Secure and parse attributes
      attributes = User.safe_attributes(params[:user])
      if attributes[:openid_url] && !attributes[:openid_url].blank?
        new_openid_url = attributes[:openid_url]
      end
      attributes[:username]   = params[:user][:username]
      attributes[:inviter_id] = @invite.user_id if @invite
      attributes[:activated]  = (!Sugar.config(:signup_approval_required) || @admin_signup)
      attributes[:admin]      = true if @admin_signup

      @user = User.create(attributes)
      if @user.valid?
        session[:user_params] = nil
        session[:invite_token] = nil
        @invite.expire! if @invite
        Mailer.new_user(@user, login_users_path(:only_path => false)).deliver if @user.email?
        @current_user = @user
        store_session_authentication

        # Verify the changed OpenID URL
        if new_openid_url
          unless start_openid_session(new_openid_url,
            :success   => update_openid_user_url(:id => @user.username),
            :fail      => edit_user_page_url(:id => @user.username, :page => 'settings')
          )
            flash[:notice] = "WARNING: Your OpenID URL is invalid!"
          end
        end
        redirect_to user_url(:id => @user.username) and return
      else
        flash.now[:notice] = "Could not create your account, please fill in all required fields."
        render :action => :new
      end
    end

    def edit
      verify_user(:user => @user, :user_admin => true, :redirect => user_url(@user))
    end

    def update_openid
      if verify_user(:user => @user, :user_admin => true, :redirect => user_url(@user))
        if session[:authenticated_openid_url] && @user.update_attribute(:openid_url, session[:authenticated_openid_url])
          flash[:notice] = "Your OpenID URL was updated!"
          redirect_to user_url(:id => @user.username) and return
        else
          flash[:notice] ||= 'OpenID verification failed!'
          redirect_to edit_user_url(:id => @user.username)
        end
      end
    end

    def update
      if verify_user(:user => @user, :user_admin => true, :redirect => user_url(@user))

        # Sanitize input
        attributes = params[:user]
        attributes = User.safe_attributes(attributes) unless @current_user.user_admin?
        attributes.delete(:administrator) unless @current_user.admin?

        if attributes[:openid_url] && attributes[:openid_url] != @user.openid_url
          new_openid_url = attributes[:openid_url]
          attributes.delete(:openid_url)
        end

        @user.update_attributes(attributes)
        if @user.valid?
          if @user == @current_user
            # Make sure the session data is updated
            @current_user.reload
            store_session_authentication
          end
          # Verify the changed OpenID URL
          if new_openid_url
            unless start_openid_session(new_openid_url,
              :success   => update_openid_user_url(:id => @user.username),
              :fail      => edit_user_page_url(:id => @user.username, :page => @page)
            )
              flash.now[:notice] = "That's not a valid OpenID URL!"
              render :action => :edit
            end
          else
            flash[:notice] = "Your changes were saved!"
            redirect_to edit_user_page_url(:id => @user.username, :page => @page) and return
          end
        else
          flash.now[:notice] ||= "There were errors saving your changes"
          render :action => :edit
        end
      end
    end

    def login
      redirect_to new_user_path   and return if @admin_signup
      redirect_to discussions_url and return if @current_user

      if request.post?
        if !params[:username].blank? && !params[:password].blank?
          user = User.find_by_username(params[:username])
          if user && user.valid_password?(params[:password])
            @current_user = user
            user.hash_password!(params[:password]) if user.password_needs_rehash?
            store_session_authentication
            redirect_to discussions_url and return
          end
        end
        unless @current_user
          flash.now[:notice] ||= "<strong>Oops!</strong> That’s not a valid username or password."
        end
      end
    end

    def password_reset
      if request.post? && params[:email]
        @user = User.find_by_email(params[:email])
        if @user
          if @user.activated? && !@user.banned?
            @user.generate_new_password!
            Mailer.password_reminder(@user, login_users_path(:only_path => false)).deliver
            @user.save
            flash[:notice] = "A new password has been mailed to you"
          else
            flash[:notice] = "Your account isn't active, you can't do that yet"
          end
        else
          flash[:notice] = "Could not find that email address"
          redirect_to password_reset_users_url and return
        end
        redirect_to login_users_url
      else
        # Render form
      end
    end

    def logout
      deauthenticate!
      flash[:notice] = "You have been logged out."
      redirect_to Sugar.public_browsing? ? discussions_url : login_users_url
    end

    def grant_invite
      unless @current_user.user_admin?
        flash[:notice] = "You don't have permission to do that!"
        redirect_to user_url(:id => @user.username) and return
      end
      @user.grant_invite!
      flash[:notice] = "#{@user.username} has been granted one invite."
      redirect_to user_url(:id => @user.username) and return
    end

    def revoke_invites
      unless @current_user.user_admin?
        flash[:notice] = "You don't have permission to do that!"
        redirect_to user_url(:id => @user.username) and return
      end
      @user.revoke_invite!(:all)
      flash[:notice] = "#{@user.username} has been revoked of all invites."
      redirect_to user_url(:id => @user.username) and return
    end
end
