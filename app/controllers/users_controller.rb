# frozen_string_literal: true

require "open-uri"

class UsersController < ApplicationController
  requires_authentication except: %i[login authenticate logout new create]
  requires_user only: %i[edit update]
  requires_user_admin only: %i[grant_invite revoke_invites]

  include CreateUserController
  include LoginUsersController
  include UsersListController

  before_action :check_status

  before_action :load_user,
                only: %i[show edit update destroy participated discussions posts
                         grant_invite revoke_invites stats]

  before_action :detect_edit_page, only: %i[edit update]
  before_action :verify_editable,  only: %i[edit update]

  def show
    respond_to do |format|
      format.html { @posts = user_posts(@user).limit(15) }
      format.mobile {}
      format.json do
        serializer = UserSerializer.new(@user, params: { context: self })
        render json: serializer.serialized_json
      end
    end
  end

  def discussions
    @discussions = @user.discussions
                        .viewable_by(current_user)
                        .page(params[:page]).for_view
    respond_with_exchanges(@discussions)
  end

  def participated
    @section = :participated if @user == current_user
    @discussions = @user.participated_discussions
                        .viewable_by(current_user)
                        .page(params[:page]).for_view
    respond_with_exchanges(@discussions)
  end

  def posts
    @posts = user_posts(@user)
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

  def edit; end

  def update
    updated = update_user
    respond_with_user(@user) do
      if updated
        flash[:notice] = t("flash.changes_saved")
        redirect_to edit_user_page_url(id: @user.username, page: @page)
      else
        flash.now[:notice] = t("flash.invalid_record")
        render action: :edit
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
    @user = User.find_by(username: params[:id]) || User.find(params[:id])
  end

  def detect_edit_page
    pages = %w[admin info location services settings hiatus]
    @page = pages.include?(params[:page]) ? params[:page] : "info"
  end

  def verify_editable
    return unless verify_user(user: @user,
                              user_admin: true,
                              redirect: user_profile_url(@user.username))
  end

  def allowed_admin_params
    return [] unless current_user? && current_user.admin?

    [:admin]
  end

  def allowed_params
    [:birthday, :description, :email, :facebook_uid,
     :latitude, :location, :longitude, :mobile_stylesheet_url,
     :mobile_theme, :notify_on_message, :realname,
     :stylesheet_url, :theme, :time_zone, :website,
     :password, :confirm_password, :hiatus_until, :preferred_format,
     avatar_attributes: [:file]] +
      allowed_user_admin_params + allowed_admin_params
  end

  def allowed_user_admin_params
    return [] unless current_user&.user_admin?

    %i[username user_admin moderator available_invites
       status banned_until]
  end

  def check_status
    # TODO: This is a bit dirty, and should be handled by ActiveJob
    # instead.
    User.temporarily_deactivated.each(&:check_status!)
  end

  def respond_with_user(user)
    respond_to do |format|
      format.any(:html, :mobile) { yield }
      format.json { render json: UserSerializer.new(user).serialized_json }
    end
  end

  def update_user
    return nil unless @user.update(user_params)

    current_user.reload if @user == current_user
    @user
  end

  def user_params
    params.require(:user).permit(*allowed_params)
  end

  def user_posts(user)
    user.discussion_posts
        .viewable_by(current_user)
        .page(params[:page]).for_view_with_exchange.reverse_order
  end
end
