# encoding: utf-8

require "open-uri"

class UsersController < ApplicationController
  requires_authentication except: [
    :login, :authenticate, :logout, :new, :create
  ]
  requires_user only: [:edit, :update]
  requires_user_admin only: [:grant_invite, :revoke_invites]

  include CreateUserController
  include LoginUsersController
  include UsersListController

  before_action :load_user,
                only: [
                  :show, :edit,
                  :update, :destroy,
                  :participated, :discussions,
                  :posts,
                  :grant_invite, :revoke_invites,
                  :stats
                ]

  before_action :detect_edit_page, only: [:edit, :update]
  before_action :verify_editable,  only: [:edit, :update]

  respond_to :html, :mobile, :xml, :json

  def show
    respond_with(@user) do |format|
      format.html do
        @posts = @user
                 .discussion_posts
                 .viewable_by(current_user)
                 .limit(15)
                 .page(params[:page])
                 .for_view_with_exchange
                 .reverse_order
      end
    end
  end

  def discussions
    @discussions = @user
                   .discussions
                   .viewable_by(current_user)
                   .page(params[:page])
                   .for_view
    respond_with_exchanges(@discussions)
  end

  def participated
    @section = :participated if @user == current_user
    @discussions = @user
                   .participated_discussions
                   .viewable_by(current_user)
                   .page(params[:page])
                   .for_view
    respond_with_exchanges(@discussions)
  end

  def posts
    @posts = @user
             .discussion_posts
             .viewable_by(current_user)
             .page(params[:page])
             .for_view_with_exchange
             .reverse_order
  end

  def stats
    @posts_per_week = Post.find_by_sql(
      "SELECT COUNT(*) AS post_count, YEAR(created_at) AS year, " \
        "WEEK(created_at) AS week " \
        "FROM posts " \
        "WHERE user_id = #{@user.id} " \
        "GROUP BY YEAR(created_at), WEEK(created_at);"
    )
    @max_posts_per_week = @posts_per_week.map { |p| p.post_count.to_i }.max
  end

  def edit
  end

  def update
    respond_with(@user) do |format|
      if @user.update_attributes(user_params)
        current_user.reload if @user == current_user
        format.any(:html, :mobile) do
          flash[:notice] = "Your changes were saved!"
          redirect_to edit_user_page_url(id: @user.username, page: @page)
        end
      else
        flash.now[:notice] = "Couldn't save your changes, " \
                             "did you fill in all required fields?"
        format.any(:html, :mobile) { render action: :edit }
      end
    end
  end

  def grant_invite
    @user.grant_invite!
    flash[:notice] = "#{@user.username} has been granted one invite."
    redirect_to user_profile_url(id: @user.username)
  end

  def revoke_invites
    @user.revoke_invite!(:all)
    flash[:notice] = "#{@user.username} has been revoked of all invites."
    redirect_to user_profile_url(id: @user.username)
  end

  private

  def load_user
    @user = User.find_by_username(params[:id]) || User.find(params[:id])
  end

  def detect_edit_page
    pages = %w(admin info location services settings temporary_ban)
    @page = params[:page] if pages.include?(params[:page])
    @page ||= "info"
  end

  def verify_editable
    return unless verify_user(
      user: @user,
      user_admin: true,
      redirect: user_profile_url(@user.username)
    )
  end

  def allowed_admin_params
    return [] unless current_user? && current_user.admin?
    [:admin]
  end

  def allowed_params
    [
      :aim, :birthday, :description, :email,
      :facebook_uid, :flickr, :gamertag, :gtalk, :instagram,
      :last_fm, :latitude, :location, :longitude, :mobile_stylesheet_url,
      :mobile_theme, :msn, :notify_on_message, :realname,
      :stylesheet_url, :theme, :time_zone, :twitter, :website,
      :password, :confirm_password, :banned_until, :preferred_format,
      :sony, :nintendo, :steam, :battlenet,
      avatar_attributes: [:file]
    ] + allowed_user_admin_params + allowed_admin_params
  end

  def allowed_user_admin_params
    return [] unless current_user? && current_user.user_admin?
    [
      :username, :banned, :user_admin, :moderator,
      :trusted, :available_invites, :status
    ]
  end

  def user_params
    params.require(:user).permit(*allowed_params)
  end
end
