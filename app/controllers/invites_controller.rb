# encoding: utf-8

class InvitesController < ApplicationController
  requires_authentication except: [:accept]
  requires_user except: [:accept]
  requires_user_admin only: [:all]

  respond_to :html, :mobile, :xml, :json

  before_action :find_invite, only: [:show, :edit, :update, :destroy]
  before_action :find_invite_by_token, only: [:accept]
  before_action :verify_available_invites, only: [:new, :create]

  def index
    respond_with(@invites = current_user.invites.active)
  end

  def all
    respond_with(@invites = Invite.active)
  end

  def accept
    session[:invite_token] = session_invite_token(@invite)
    if expire_invite(@invite)
      flash[:notice] ||= "Your invite has expired!"
    elsif @invite
      redirect_to new_user_by_token_url(token: @invite.token)
      return
    else
      flash[:notice] ||= "That's not a valid invite!"
    end
    redirect_to login_users_url
  end

  def new
    respond_with(@invite = current_user.invites.new)
  end

  def create
    @invite = create_invite(invite_params)

    if !@invite.valid?
      render action: :new
      return
    elsif deliver_invite!(@invite)
      flash[:notice] = t("invite.sent", email: @invite.email)
    else
      flash[:notice] = t("invite.failed", email: @invite.email)
    end
    redirect_to invites_url
  end

  def destroy
    if verify_user(user: @invite.user, user_admin: true)
      @invite.destroy
      flash[:notice] = "Your invite has been cancelled."
      redirect_to invites_url
    end
  end

  private

  def create_invite(attrs)
    current_user.invites.create(attrs)
  end

  def deliver_invite!(invite)
    Mailer.invite(invite, accept_invite_url(id: invite.token)).deliver_now
  rescue Net::SMTPFatalError, Net::SMTPSyntaxError
    @invite.destroy
    false
  end

  def expire_invite(invite)
    return false unless invite && invite.expired?
    @invite.destroy
  end

  def invite_params
    params.require(:invite).permit(:email, :message)
  end

  # Finds the requested invite
  def find_invite
    @invite = Invite.find(params[:id])
  end

  def find_invite_by_token
    @invite = Invite.find_by_token(params[:id])
  end

  def session_invite_token(invite)
    return nil unless invite && !invite.expired?
    invite.token
  end

  def verify_available_invites
    return if current_user? && current_user.available_invites?
    respond_to do |format|
      format.any(:html, :mobile) do
        flash[:notice] = "You don't have any invites!"
        redirect_to online_users_url
      end
      format.any(:xml, :json) do
        render(text: "You don't have any invites!", status: :method_not_allowed)
      end
    end
  end
end
