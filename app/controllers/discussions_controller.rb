# frozen_string_literal: true

class DiscussionsController < ApplicationController
  include ExchangesController

  requires_authentication
  requires_user except: %i[index search search_posts show]

  before_action :find_exchange, except: %i[
    index new create popular search favorites following hidden
  ]
  before_action :verify_editable, only: %i[edit update destroy]
  before_action :require_and_set_search_query, only: %i[search search_posts]

  def index
    scope = current_user&.unhidden_discussions || Discussion
    @exchanges = scope.viewable_by(current_user).page(params[:page]).for_view
    respond_with_exchanges(@exchanges)
  end

  def popular
    @days = params[:days].to_i
    @days = 180 if @days > 180
    @exchanges = Discussion.popular_in_the_last(@days.days)
                           .viewable_by(current_user).page(params[:page])
    respond_with_exchanges(@exchanges)
  end

  def search
    @exchanges = search_results.results
    @search_path = search_path
    respond_to do |format|
      format.any(:html, :mobile) { respond_with_exchanges(@exchanges) }
      format.json do
        render json: @exchanges
      end
    end
  end

  def favorites
    @section = :favorites
    @exchanges = user_discussions(:favorite_discussions)
    respond_with_exchanges(@exchanges)
  end

  def following
    @section = :following
    @exchanges = user_discussions(:followed_discussions)
    respond_with_exchanges(@exchanges)
  end

  def hidden
    @exchanges = user_discussions(:hidden_discussions)
    respond_with_exchanges(@exchanges)
  end

  def new
    @exchange = Discussion.new
    render template: "exchanges/new"
  end

  def create
    @exchange = Discussion.create(exchange_params.merge(poster: current_user))
    if @exchange.valid?
      redirect_to @exchange
    else
      flash.now[:notice] = "Could not save your discussion! " \
                           "Please make sure all required fields are filled in."
      render template: "exchanges/new"
    end
  end

  def follow
    define_relationship(:following, true)
  end

  def unfollow
    define_relationship(:following, false, back_to_index: true)
  end

  def favorite
    define_relationship(:favorite, true)
  end

  def unfavorite
    define_relationship(:favorite, false, back_to_index: true)
  end

  def hide
    define_relationship(:hidden, true, back_to_index: true)
  end

  def unhide
    define_relationship(:hidden, false)
  end

  private

  def define_relationship(key, value, back_to_index: false)
    DiscussionRelationship.define(current_user, @exchange, key => value)
    if back_to_index
      redirect_to discussions_url
    else
      redirect_to discussion_url(@exchange, page: params[:page])
    end
  end

  def exchange_params
    params.require(:discussion)
          .permit(%i[title body format nsfw closed] +
                  (current_user.trusted? ? [:trusted] : []) +
                  (current_user.moderator? ? [:sticky] : []))
  end

  def find_exchange
    @exchange = Exchange.find(params[:id])

    if !@exchange.is_a?(Discussion)
      redirect_to @exchange
    elsif !@exchange.viewable_by?(current_user)
      render_error 403
    end
  end

  def search_results
    @search_results ||= Discussion.search_results(search_query,
                                                  user: current_user,
                                                  page: params[:page])
  end

  def user_discussions(method)
    current_user.send(method)
                .viewable_by(current_user).page(params[:page]).for_view
  end
end
