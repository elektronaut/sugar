# frozen_string_literal: true

module SearchableExchange
  extend ActiveSupport::Concern
  include PgSearch::Model

  included do
    pg_search_scope(
      :search_by_title,
      against: :title,
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
      search_by_title(search_query)
        .reorder("last_post_at DESC")
        .for_view
    end
  end
end
