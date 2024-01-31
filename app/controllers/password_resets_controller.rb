# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  before_action :find_by_token, only: %i[show update]

  def show; end

  def new; end

  def create
    @user = User.where(email: params[:email]).first if params[:email]
    deliver_password_reset(@user) if @user
    flash[:notice] = t("password_reset.sent")
    redirect_to login_users_url
  end

  def update
    if user_params[:password].present? && @user.update(user_params)
      authenticate!(@user)
      flash[:notice] = t("password_reset.changed")
      redirect_to root_url
    else
      render action: :show
    end
  end

  private

  def deliver_password_reset(user)
    Mailer.password_reset(
      user.email,
      recovery_url(user)
    ).deliver_later
  end

  def fail_reset(message)
    flash[:notice] = message
    redirect_to login_users_url
  end

  def find_by_token
    @token = params[:token]
    @user = validate_token(@token)
    return if @user

    fail_reset(t("password_reset.expired"))
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    fail_reset(t("password_reset.invalid"))
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def reset_message_verifier
    Rails.application.message_verifier(:password_reset)
  end

  def recovery_token(user)
    reset_message_verifier.generate(
      { id: user.id, valid_until: 24.hours.from_now }
    )
  end

  def recovery_url(user)
    password_reset_url(token: recovery_token(user))
  end

  def validate_token(token)
    message = reset_message_verifier.verify(token)
    return unless message[:valid_until] >= Time.zone.now

    User.find(message[:id])
  end
end
