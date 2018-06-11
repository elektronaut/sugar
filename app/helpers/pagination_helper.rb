# frozen_string_literal: true

module PaginationHelper
  def nearest_pages(collection, number = 9)
    first = [collection.current_page - (number / 2), 1].max
    last = [first + (number - 1), collection.total_pages].min
    first = [last - (number - 1), 1].max if (last - first) < number
    (first..last).to_a
  end
end
