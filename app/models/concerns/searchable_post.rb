module SearchablePost
  extend ActiveSupport::Concern

  included do
    searchable do
      text :body
      integer :user_id
      integer :exchange_id
      time :created_at
      time :updated_at
      boolean :trusted
      boolean :conversation
      boolean :deleted
    end
  end

  module ClassMethods
    def search_results(query, options = {})
      perform_search(
        query,
        options[:page],
        (options[:user] && options[:user].trusted?),
        options[:exchange]
      ).results
    end

    private

    def perform_search(query, page, trusted, exchange)
      Post.search do
        fulltext(query)
        with(:deleted, false)
        with(:trusted, false) unless trusted
        with(:exchange_id, exchange.id) if exchange
        with(:conversation, false) unless exchange
        order_by(:created_at, :desc)
        paginate(page: page, per_page: Post.per_page)
      end
    end
  end
end
