module PaginationHelper
  def nearest_pages(collection, number = 9)
    first = collection.current_page - (number / 2)
    first = 1 if first < 1
    last  = first + (number - 1)
    last  = collection.total_pages if last > collection.total_pages
    if (last - first) < number
      first = last - (number - 1)
      first = 1 if first < 1
    end
    (first..last).to_a
  end
end
