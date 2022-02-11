# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  before_action :find_user_by_email, only: %i[create]
  before_action :require_user, only: %i[create]
  before_action :find_password_reset_token, only: %i[show update]
  before_action :check_for_expired_token, only: %i[show update]

  def new; end

  def create
    @password_reset_token = @user.password_reset_tokens.create
    deliver_password_reset(@user, @password_reset_token)
    flash[:notice] = "An email with further instructions has been sent"
    redirect_to login_users_url
  end

  def show
    @user = @password_reset_token.user
  end

  def update
    @user = @password_reset_token.user
    if user_params[:password].present? && @user.update(user_params)
      @password_reset_token.destroy
      authenticate!(@user)
      flash[:notice] = "Your password has been changed"
      redirect_to root_url
    else
      render action: :show
    end
  end

  private

  def deliver_password_reset(user, password_reset_token)
    Mailer.password_reset(
      user.email,
      password_reset_with_token_url(
        password_reset_token,
        password_reset_token.token
      )
    ).deliver_later
  end

  def user_params
    params.require(:user).permit(:password, :confirm_password)
  end

  def find_user_by_email
    @user = User.where(email: params[:email]).first if params[:email]
  end

  def find_password_reset_token
    @password_reset_token = PasswordResetToken.find_by(id: params[:id])
    unless @password_reset_token &&
           @password_reset_token.token == params[:token]
      flash[:notice] = "Invalid password reset request"
      redirect_to login_users_url
    end
  end

  def check_for_expired_token
    return unless @password_reset_token.expired?

    @password_reset_token.destroy
    flash[:notice] = "Your password reset link has expired"
    redirect_to login_users_url
  end

  def render_user_not_found
    respond_to do |format|
      format.html.mobile do
        flash[:notice] = "Couldn't find a user with that email address"
        redirect_to login_users_url
      end
      format.html.none do
        flash.now[:notice] = "Couldn't find a user with that email address"
        render action: :new
      end
    end
  end

  def require_user
    return if @user

    render_user_not_found
  end
end
