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
    end
  end

  module ClassMethods
    def search_results(query, options = {})
      search = Post.search do
        fulltext query
        with :trusted, false unless options[:user] && options[:user].trusted?
        if options[:exchange]
          with :exchange_id, options[:exchange].id
        else
          with :conversation,  false
        end
        order_by :created_at, :desc
        paginate page: options[:page], per_page: Post.per_page
      end
      search.results
    end
  end
end
