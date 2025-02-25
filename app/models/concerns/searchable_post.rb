# frozen_string_literal: true

module SearchablePost
  extend ActiveSupport::Concern
  include PgSearch::Model

  included do
    pg_search_scope(
      :search_by_body,
      against: :body,
      ignoring: :accents,
      using: {
        tsearch: {
          negation: true,
          dictionary: "english",
          tsvector_column: "tsv"
        }
      }
    )
  end

  module ClassMethods
    def search(search_query)
      where(conversation: false, deleted: false)
        .search_by_body(search_query)
        .reorder("created_at DESC")
        .for_view_with_exchange
    end

    def search_in_exchange(search_query)
      where(deleted: false)
        .search_by_body(search_query)
        .for_view
        .reorder("created_at DESC")
    end
  end
end
