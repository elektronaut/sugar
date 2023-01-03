# frozen_string_literal: true

module ExchangeResponder
  extend ActiveSupport::Concern

  def respond_with_exchanges(exchanges)
    respond_to do |format|
      format.html { viewed_tracker.exchanges = exchanges }
      format.json { render json: ExchangeResource.new(exchanges) }
    end
  end
end
