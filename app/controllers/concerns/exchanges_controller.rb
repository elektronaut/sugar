# encoding: utf-8

module ExchangesController
  extend ActiveSupport::Concern

  included do
    protect_from_forgery except: [:mark_as_read]
    respond_to :html, :mobile, :json
  end

  def search_posts
    @search_path = polymorphic_path([:search_posts, @exchange])
    @posts = Post.search_results(search_query, user: current_user, exchange: @exchange, page: params[:page])
    render template: "exchanges/search_posts"
  end

  def show
    context = (request.format == :mobile) ? 0 : 3
    @posts = @exchange.posts.page(params[:page], context: context).for_view

    # Mark discussion as viewed
    if current_user?
      current_user.mark_exchange_viewed(@exchange, @posts.last, (@posts.offset_value + @posts.count))
    end

    respond_with(@exchange)
  end

  def edit
    @exchange.body = @exchange.posts.first.body
    render template: "exchanges/edit"
  end

  def update
    @exchange.update_attributes(exchange_params.merge(updated_by: current_user))
    if @exchange.valid?
      flash[:notice] = "Your changes were saved."
      redirect_to @exchange
    else
      flash.now[:notice] = "Could not save your discussion! Please make sure all required fields are filled in."
      render template: "exchanges/edit"
    end
  end

  def mark_as_read
    current_user.mark_exchange_viewed(@exchange, @exchange.posts.last, @exchange.posts_count)
    if request.xhr?
      render layout: false, text: 'OK'
    end
  end

  protected

  def verify_editable
    unless @exchange.editable_by?(current_user)
      render_error 403 and return
    end
  end

  def search_query
    params[:query] || params[:q]
  end

  def require_and_set_search_query
    unless @search_query = search_query
      flash[:notice] = "No query specified!"
      redirect_to root_url and return
    end
  end

end
