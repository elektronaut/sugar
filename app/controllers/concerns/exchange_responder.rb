# frozen_string_literal: true

module ExchangeResponder
  extend ActiveSupport::Concern

  def respond_with_exchanges(exchanges)
    viewed_tracker.exchanges = exchanges
    respond_to do |format|
      format.html
      format.json do
        serializer = exchange_responser_serializer(exchanges, viewed_tracker)
        render json: serializer.serialized_json
      end
    end
  end

  private

  def exchange_responser_serializer(exchanges, viewed_tracker)
    ExchangeSerializer.new(
      exchanges,
      include: %i[poster last_poster],
      links: { self: paginated_json_path(exchanges.current_page),
               next: paginated_json_path(exchanges.next_page),
               previous: paginated_json_path(exchanges.previous_page) },
      params: { tracker: viewed_tracker }
    )
  end
end
