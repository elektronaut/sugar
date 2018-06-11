# frozen_string_literal: true

require "digest/sha1"

class PostsController < ApplicationController
  include DrawingsController

  caches_page :count

  requires_authentication except: %i[count]
  requires_user except: %i[count since search]
  protect_from_forgery except: %i[drawing]

  before_action :find_exchange, except: %i[search]
  before_action :verify_viewable, except: %i[search count since]
  before_action :find_post, only: %i[show edit update destroy]
  before_action :find_post, only: %i[show edit update destroy]
  before_action :verify_editable, only: %i[edit update destroy]
  before_action :require_and_set_search_query, only: %i[search]
  before_action :verify_postable, only: %i[create drawing]

  after_action :mark_exchange_viewed, only: %i[since]
  after_action :mark_conversation_viewed, only: %i[since]
  # after_action :notify_mentioned, only: [:create]

  respond_to :html, :mobile, :json

  def count
    @count = @exchange.posts_count
    respond_to do |format|
      format.json { render json: { posts_count: @count }.to_json }
    end
  end

  def since
    @posts = @exchange.posts.limit(200).offset(params[:index]).for_view
    render layout: false if request.xhr?
  end

  def search
    @search_path = search_posts_path
    @posts = Post.search_results(search_query,
                                 user: current_user, page: params[:page])
  end

  def create
    create_post(post_params.merge(user: current_user))
  rescue URI::InvalidURIError => e
    render_post_error(e.message)
  end

  def update
    @post.update(post_params.merge(edited_at: Time.now.utc))
    respond_with(@post, location: polymorphic_url(@exchange,
                                                  page: @post.page,
                                                  anchor: "post-#{@post.id}"))
  end

  def preview
    @post = @exchange.posts.new(post_params.merge(user: current_user))
    @post.fetch_images
    @post.body_html # Render post to trigger any errors
    render layout: false if request.xhr?
  rescue URI::InvalidURIError => e
    render_post_error(e.message)
  end

  def edit
    render layout: false if request.xhr?
  end

  private

  def create_post(create_params)
    @post = @exchange.posts.create(create_params)
    @exchange.reload

    exchange_url = polymorphic_url(@exchange,
                                   page: @exchange.last_page,
                                   anchor: "post-#{@post.id}")

    # if @exchange.is_a?(Conversation)
    #   ConversationNotifier.new(@post, exchange_url).deliver_later
    # end

    respond_with(@post, location: exchange_url)
  end

  def find_exchange
    @exchange = if params[:discussion_id]
                  Discussion.find(params[:discussion_id])
                elsif params[:conversation_id]
                  Conversation.find(params[:conversation_id])
                else
                  Exchange.find(params[:exchange_id])
                end
  end

  def find_post
    @post = Post.find(params[:id])
  end

  def mark_conversation_viewed
    return unless @exchange.is_a?(Conversation)
    current_user.mark_conversation_viewed(@exchange)
  end

  def mark_exchange_viewed
    return unless current_user? && @posts.any?
    current_user.mark_exchange_viewed(@exchange,
                                      @posts.last,
                                      (params[:index].to_i + @posts.length))
  end

  # def notify_mentioned
  #   if @post.valid? && @post.mentions_users?
  #     @post.mentioned_users.each do |mentioned_user|
  #       logger.info "Mentions: #{mentioned_user.username}"
  #     end
  #   end
  # end

  def post_params
    params.require(:post).permit(:body, :format)
  end

  def search_query
    params[:query] || params[:q]
  end

  def render_post_error(msg)
    render plain: msg, status: :internal_server_error if request.xhr?
  end

  def require_and_set_search_query
    @search_query = search_query
    return if @search_query
    flash[:notice] = "No query specified!"
    redirect_to root_url
  end

  def verify_editable
    return if @post.editable_by?(current_user)
    flash[:notice] = "You don't have permission to edit that post!"
    redirect_to polymorphic_url(@exchange, page: @exchange.last_page)
  end

  def verify_postable
    return if @exchange.postable_by?(current_user)
    flash[:notice] = "This discussion is closed, " \
                     "you don't have permission to post here"
    redirect_to polymorphic_url(@exchange, page: @exchange.last_page)
  end

  def verify_viewable
    return if @exchange&.viewable_by?(current_user)
    flash[:notice] = "You don't have permission to view that discussion!"
    redirect_to root_url
  end
end
