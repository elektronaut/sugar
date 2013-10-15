# encoding: utf-8

class ConversationsController < ApplicationController
  include ExchangesController

  requires_authentication
  requires_user

  before_filter :find_exchange, except: [:index, :new, :create]
  before_filter :verify_editable, only: [:edit, :update, :destroy]
  before_filter :find_recipient, only: [:create]
  before_filter :require_and_set_search_query, only: [:search, :search_posts]

  def index
    @exchanges = current_user.conversations.page(params[:page]).for_view
    load_views_and_respond_with(@exchanges)
  end

  def show
    super
    current_user.mark_conversation_viewed(@exchange)
  end

  def new
    @exchange = Conversation.new
    @recipient = User.find_by_username(params[:username]) if params[:username]
    render template: "exchanges/new"
  end

  def create
    @exchange = Conversation.create(exchange_params.merge(poster: current_user))
    if @exchange.valid?
      @exchange.add_participant(@recipient) if @recipient
      redirect_to @exchange
    else
      flash.now[:notice] = "Could not save your conversation! Please make sure all required fields are filled in."
      render template: "exchanges/new"
    end
  end

  def edit
    super
  end

  def update
    super
  end

  def invite_participant
    if params[:username]
      usernames = params[:username].split(/\s*,\s*/)
      usernames.each do |username|
        if user = User.find_by_username(username)
          @exchange.add_participant(user)
        end
      end
    end
    if request.xhr?
      render template: 'conversations/participants', layout: false
    else
      redirect_to @exchange
    end
  end

  def remove_participant
    @exchange.remove_participant(current_user)
    flash[:notice] = 'You have been removed from the conversation'
    redirect_to conversations_url and return
  end

  private

  def exchange_params
    params.require(:conversation).permit(:recipient_id, :title, :body, :format, :recipient_id)
  end

  def find_exchange
    begin
      @exchange = Conversation.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_error 404 and return
    end

    unless @exchange.viewable_by?(current_user)
      render_error 403 and return
    end
  end

  def find_recipient
    if params[:recipient_id]
      begin
        @recipient = User.find(params[:recipient_id])
      rescue ActiveRecord::RecordNotFound
        @recipient = nil
      end
    end
  end

end