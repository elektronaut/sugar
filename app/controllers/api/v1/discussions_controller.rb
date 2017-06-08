class Api::V1::DiscussionsController < Api::V1::ApiController
  before_action :doorkeeper_authorize!
  respond_to :json
  before_action :find_exchange, only: [:show]

  def index
    @exchanges = current_resource_owner
                 .unhidden_discussions
                 .viewable_by(current_resource_owner)
                 .page(params[:page])
                 .for_view
    respond_with @exchanges
  end

  def show
    respond_with @exchange
  end

  def search
    search = Discussion.search_results(
      params[:query],
      user: current_resource_owner,
      page: params[:page]
    )
    respond_with search.results, meta: {
      total: search.total
    }
  end

  private

  def find_exchange
    @exchange = Discussion.find(params[:id])
    unless @exchange.viewable_by?(current_resource_owner)
      render json: { error: "forbidden" }.to_json, status: 403
      return
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "not-found" }.to_json, status: 404
    return
  end
end
