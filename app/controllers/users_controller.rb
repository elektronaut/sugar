# encoding: utf-8

require 'open-uri'

class UsersController < ApplicationController
  requires_authentication :except => [:login, :authenticate, :logout, :new, :create]
  requires_user           :only   => [:edit, :update, :update_openid]
  requires_user_admin     :only   => [:grant_invite, :revoke_invites]

  include CreateUserController
  include LoginUsersController
  include OpenidUserController
  include UsersListController

  before_filter :load_user,
                :only => [
                  :show, :edit,
                  :update, :destroy,
                  :participated, :discussions,
                  :posts, :update_openid,
                  :grant_invite, :revoke_invites,
                  :stats
                ]

  before_filter :detect_edit_page, :only => [:edit, :update]
  before_filter :verify_editable,  :only => [:edit, :update, :update_openid]

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

    def verify_editable
      return unless verify_user(:user => @user, :user_admin => true, :redirect => user_url(@user))
    end

    def allowed_params
      allowed = [
        :aim, :application, :avatar_url, :birthday, :description, :email,
        :facebook_uid, :flickr, :gamertag, :gtalk, :html_disabled, :instagram,
        :last_fm, :latitude, :location, :longitude, :mobile_stylesheet_url,
        :mobile_theme, :msn, :notify_on_message, :realname,
        :stylesheet_url, :theme, :time_zone, :twitter, :website,
        :password, :confirm_password, :banned_until
      ]
      if @current_user
        if @current_user.user_admin?
          allowed += [
            :username, :banned, :activated, :user_admin, :moderator,
            :trusted, :available_invites, :status
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

  public

    def show
      respond_with(@user) do |format|
        format.html do
          @posts = @user.discussion_posts.viewable_by(@current_user).limit(15).page(params[:page]).for_view_with_discussion.reverse_order
        end
      end
    end

    def discussions
      @discussions = @user.discussions.viewable_by(@current_user).page(params[:page]).for_view
      load_views_for(@discussions)
    end

    def participated
      @section = :participated if @user == @current_user
      @discussions = @user.participated_discussions.viewable_by(@current_user).page(params[:page]).for_view
      load_views_for(@discussions)
    end

    def posts
      @posts = @user.discussion_posts.viewable_by(@current_user).page(params[:page]).for_view_with_discussion.reverse_order
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
