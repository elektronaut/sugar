module SearchableExchange
  extend ActiveSupport::Concern

  included do
    searchable do
      text    :title
      string  :type
      integer :poster_id
      integer :last_poster_id
      integer :category_id
      boolean :trusted
      boolean :closed
      boolean :sticky
      time    :created_at
      time    :updated_at
      time    :last_post_at
    end
  end

  module ClassMethods
    # Searches exchanges
    #
    # === Parameters
    # * :query    - The query string
    # * :page     - Page number, starting on 1 (default: first page)
    # * :limit    - Number of posts per page (default: 20)
    # * :trusted  - Boolean, get trusted posts as well (default: false)
    def search_paginated(options={})
      page  = (options[:page] || 1).to_i
      page = 1 if page < 1

      search = self.search do
        fulltext options[:query]
        with     :trusted, false unless options[:trusted]
        order_by :last_post_at, :desc
        paginate :page => page, :per_page => options[:limit] || Exchange::DISCUSSIONS_PER_PAGE
      end

      Pagination.apply(
        search.results,
        Pagination::Paginater.new(
          :total_count => search.total,
          :page        => page,
          :per_page    => options[:limit] || Exchange::DISCUSSIONS_PER_PAGE
        )
      )
    end
  end

end