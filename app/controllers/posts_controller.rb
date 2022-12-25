# frozen_string_literal: true

require "digest/sha1"

class PostsController < ApplicationController
  include PostingController

  caches_page :count

  requires_authentication except: %i[count]
  requires_user except: %i[count since search]

  before_action :find_exchange, except: %i[search]
  before_action :find_post, only: %i[edit update]
  before_action :verify_editable, only: %i[edit update]
  before_action :verify_postable, only: %i[create]
  before_action :verify_viewable, except: %i[search count]
  before_action :require_and_set_search_query, only: %i[search]

  after_action :mark_exchange_viewed, only: %i[since index]
  after_action :mark_conversation_viewed, only: %i[since index]
  # after_action :notify_mentioned, only: [:create]

  def index
    @page = params[:page] || 1
    @posts = @exchange.posts.page(@page, context: 0).for_view
    respond_to do |format|
      format.json do
        render json: posts_serializer(@posts).serialized_json
      end
    end
  end

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

  def edit
    render layout: false if request.xhr?
  end

  def create
    create_post(post_params.merge(user: current_user))
  rescue URI::InvalidURIError => e
    render_post_error(e.message)
  end

  def update
    @post.update(post_params.merge(edited_at: Time.now.utc))

    post_url = polymorphic_url(@exchange,
                               page: @post.page, anchor: "post-#{@post.id}")

    respond_with_updated_post(@post, post_url)
  end

  def preview
    @post = build_preview_post(@exchange, post_params.merge(user: current_user))
    render layout: false if request.xhr?
  rescue URI::InvalidURIError => e
    render_post_error(e.message)
  end

  private

  def find_exchange
    @exchange = if params[:discussion_id]
                  Discussion.find(params[:discussion_id])
                elsif params[:conversation_id]
                  Conversation.find(params[:conversation_id])
                else
                  Exchange.find(params[:exchange_id])
                end
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

  def posts_serializer(posts)
    PostSerializer.new(
      posts,
      links: { self: paginated_json_path(posts.current_page),
               next: paginated_json_path(posts.next_page),
               previous: paginated_json_path(posts.previous_page) },
      include: %i[user]
    )
  end

  def search_query
    params[:query] || params[:q]
  end

  def require_and_set_search_query
    @search_query = search_query
    return if @search_query

    flash[:notice] = t("exchange.no_query")
    redirect_to root_url
  end

  def verify_viewable
    return if @exchange&.viewable_by?(current_user)

    flash[:notice] = t("exchange.not_viewable")
    redirect_to root_url
  end
end
