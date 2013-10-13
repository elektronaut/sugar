# encoding: utf-8

class DiscussionsController < ExchangesController
  include ConversationController

  before_filter :load_categories,    only: [:new, :create, :edit, :update]
  before_filter :require_categories, only: [:new, :create]

  def index
    if current_user?
      @exchanges = current_user.unhidden_discussions.viewable_by(current_user).page(params[:page]).for_view
    else
      @exchanges = Discussion.viewable_by(nil).page(params[:page]).for_view
    end
    load_views_for(@exchanges)
  end

  def popular
    @days = params[:days].to_i
    unless (1..180).include?(@days)
      redirect_to params.merge({days: 7}) and return
    end
    @exchanges = Discussion.viewable_by(current_user).popular_in_the_last(@days.days).page(params[:page])
    load_views_for(@exchanges)
  end

  def search
    @exchanges = Discussion.search_results(search_query, user: current_user, page: params[:page])

    respond_to do |format|
      format.any(:html, :mobile) do
        load_views_for(@exchanges)
        @search_path = search_path
      end
      format.json do
        json = {
          pages:         @exchanges.pages,
          total_entries: @exchanges.total,
          # TODO: Fix when Rails bug is fixed
          #discussions:   @exchanges
          discussions:   @exchanges.map{|d| {discussion: d.attributes}}
        }.to_json(except: [:delta])
        render text: json
      end
    end
  end

  def favorites
    @section = :favorites
    @exchanges = current_user.favorite_discussions.viewable_by(current_user).page(params[:page]).for_view
    load_views_for(@exchanges)
  end

  def following
    @section = :following
    @exchanges = current_user.followed_discussions.viewable_by(current_user).page(params[:page]).for_view
    load_views_for(@exchanges)
  end

  def hidden
    @exchanges = current_user.hidden_discussions.viewable_by(current_user).page(params[:page]).for_view
    load_views_for(@exchanges)
  end

  def follow
    DiscussionRelationship.define(current_user, @exchange, following: true)
    redirect_to discussion_url(@exchange, page: params[:page])
  end

  def unfollow
    DiscussionRelationship.define(current_user, @exchange, following: false)
    redirect_to discussions_url
  end

  def favorite
    DiscussionRelationship.define(current_user, @exchange, favorite: true)
    redirect_to discussion_url(@exchange, page: params[:page])
  end

  def unfavorite
    DiscussionRelationship.define(current_user, @exchange, favorite: false)
    redirect_to discussions_url
  end

  def hide
    DiscussionRelationship.define(current_user, @exchange, hidden: true)
    redirect_to discussions_url
  end

  def unhide
    DiscussionRelationship.define(current_user, @exchange, hidden: false)
    redirect_to discussion_url(@exchange, page: params[:page])
  end

  private

  def load_categories
    @categories = Category.viewable_by(current_user)
  end

  def require_categories
    if @categories.length == 0 && exchange_class == Discussion
      flash[:notice] = "Can't create a new discussion, no categories have been made!"
      redirect_to categories_url and return
    end
  end

end