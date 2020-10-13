# frozen_string_literal: true

module SearchablePost
  extend ActiveSupport::Concern
  include Searchable

  included do
    searchable(auto_index: false,
               auto_remove: false) do
      text :body
      integer :user_id
      integer :exchange_id
      time :created_at
      time :updated_at
      boolean :conversation
      boolean :deleted
    end
  end

  module ClassMethods
    def search_results(str, options = {})
      query, user = parse_search_query(str)
      perform_search(
        query,
        options[:page],
        options[:exchange],
        user: user
      ).results
    end

    private

    def user_search_expr(user)
      Regexp.new("user:#{Regexp.quote(user.username)}", Regexp::IGNORECASE)
    end

    def parse_search_query(str)
      users = User.all.select do |user|
        str.match?(user_search_expr(user))
      end

      return [str, nil] unless users.any?

      [str.gsub(user_search_expr(users.first), ""), users.first]
    end

    def perform_search(query, page, exchange, user: nil)
      Post.search do
        fulltext(query)
        with(:deleted, false)
        with(:exchange_id, exchange.id) if exchange
        with(:conversation, false) unless exchange
        with(:user_id, user.id) if user
        order_by(:created_at, :desc)
        paginate(page: page, per_page: Post.per_page)
      end
    end
  end
end
