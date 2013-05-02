# encoding: utf-8

class DiscussionsController < ApplicationController
  requires_authentication
  requires_user           :except => [:index, :search, :search_posts, :show]
  protect_from_forgery    :except => :mark_as_read

  include ConversationController
  include DiscussionController

  before_filter :load_discussion, :only => [:show, :edit, :update, :destroy, :follow, :unfollow, :favorite, :unfavorite, :search_posts, :mark_as_read, :invite_participant, :remove_participant]
  before_filter :verify_editable, :only => [:edit, :update, :destroy]
  before_filter :set_exchange_params
  before_filter :require_and_set_search_query, :only => [:search, :search_posts]

  protected

    # Loads discussion by params[:id] and checks permissions.
    def load_discussion
      begin
        @discussion = Exchange.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error 404 and return
      end

      unless @discussion.viewable_by?(@current_user)
        render_error 403 and return
      end
    end

    # Deflects the request unless the discussion is editable by the logged in user.
    def verify_editable
      unless @discussion.editable_by?(@current_user)
        render_error 403 and return
      end
    end

    # This is pretty silly and needs rewriting.
    def set_exchange_params
      if params[:conversation]
        params[:exchange] = params[:conversation]
      elsif params[:discussion]
        params[:exchange] = params[:discussion]
      end
    end

    def search_query
      params[:query] || params[:q]
    end

    def require_and_set_search_query
      unless @search_query = search_query
        flash[:notice] = "No query specified!"
        redirect_to discussions_path and return
      end
    end

    def exchange_class
      (params[:type] == "conversation" || (params[:exchange] && params[:exchange][:type] == 'Conversation')) ? Conversation : Discussion
    end

    def exchange_params(options={})
      if @current_user.moderator?
        params.require(:exchange).permit(:recipient_id, :title, :body, :category_id, :nsfw, :closed, :sticky)
      else
        params.require(:exchange).permit(:recipient_id, :title, :body, :category_id, :nsfw, :closed)
      end
    end

  public

    # Searches posts within a discussion
    def search_posts
      @search_path = search_posts_discussion_path(@discussion)
      @posts = Post.search_results(search_query, user: @current_user, exchange: @discussion, page: params[:page])
    end

    # Creates a new discussion
    def new
      @discussion = exchange_class.new
      if exchange_class == Discussion
        @discussion.category = Category.find(params[:category_id]) if params[:category_id]
      elsif exchange_class == Conversation
        @recipient = User.find_by_username(params[:username]) if params[:username]
      end
    end

    # Show a discussion
    def show
      context = (request.format == :mobile) ? 0 : 3
      @posts = @discussion.posts.page(params[:page], context: context).for_view

      # Mark discussion as viewed
      if @current_user
        @current_user.mark_discussion_viewed(@discussion, @posts.last, (@posts.offset_value + @posts.count))
      end
      if @discussion.kind_of?(Conversation)
        @section = :conversations
        @current_user.mark_conversation_viewed(@discussion)
        render :template => 'discussions/show_conversation'
      end
    end

    # Edit a discussion
    def edit
      @discussion.body = @discussion.posts.first.body
    end

    # Create a new discussion
    def create
      @discussion = exchange_class.create(exchange_params.merge(poster: @current_user))
      if @discussion.valid?
        @discussion.add_participant(@recipient) if @recipient
        redirect_to discussion_url(@discussion)
      else
        flash.now[:notice] = "Could not save your discussion! Please make sure all required fields are filled in."
        render :action => :new
      end
    end

    # Update a discussion
    def update
      @discussion.update_attributes(exchange_params.merge(updated_by: @current_user))
      if @discussion.valid?
        flash[:notice] = "Your changes were saved."
        redirect_to discussion_path(@discussion)
      else
        flash.now[:notice] = "Could not save your discussion! Please make sure all required fields are filled in."
        render :action => :edit
      end
    end

end
