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

end