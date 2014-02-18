module CacheHelper
  def cache_key_for_posts(exchange, page)
    timestamp = [
      exchange.users.maximum(:updated_at).try(:utc),
      exchange.updated_at.try(:utc)
    ].max.try(:to_s, :number)
    "exchange/#{exchange.id}/posts-#{timestamp}-#{page}"
  end
end