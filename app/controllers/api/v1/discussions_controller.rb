# frozen_string_literal: true

module Api
  module V1
    class DiscussionsController < Api::V1::ApiController
      before_action :doorkeeper_authorize!
      before_action :find_exchange, only: [:show]

      def index
        @exchanges = current_resource_owner.unhidden_discussions
                                           .viewable_by(current_resource_owner)
                                           .page(params[:page])
                                           .for_view
        render json: @exchanges
      end

      def show
        render json: @exchange
      end

      def search
        search = Discussion.search_results(
          params[:query],
          user: current_resource_owner,
          page: params[:page]
        )
        render json: search.results, meta: { total: search.total }
      end

      private

      def find_exchange
        @exchange = Discussion.find(params[:id])
        unless @exchange.viewable_by?(current_resource_owner)
          render json: { error: "forbidden" }.to_json, status: :forbidden
          nil
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "not-found" }.to_json, status: :not_found
        nil
      end
    end
  end
end
