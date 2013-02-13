module SearchablePost
  extend ActiveSupport::Concern

  included do
    searchable do
      text    :body
      integer :user_id
      integer :discussion_id
      time    :created_at
      time    :updated_at
      boolean :trusted
      boolean :conversation
    end
  end

  module ClassMethods
    def search_paginated(options={})
      page  = (options[:page] || 1).to_i
      page = 1 if page < 1

      search = self.search do
        fulltext options[:query]
        with     :trusted, false unless options[:trusted]
        with     :conversation, (options[:conversation] || false)
        with     :discussion_id, options[:discussion_id] if options[:discussion_id]
        order_by :created_at, :desc
        paginate :page => page, :per_page => (options[:limit] || Post.per_page)
      end

      Pagination.apply(
        search.results,
        Pagination::Paginater.new(
          :total_count => search.total,
          :page        => page,
          :per_page    => (options[:limit] || Post.per_page)
        )
      )
    end
  end

end