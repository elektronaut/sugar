module Paginatable
  extend ActiveSupport::Concern

  module ClassMethods

    module Inheritance
      def inherited(subclass)
        super
        subclass.per_page = self.per_page
      end
    end

    def self.extended(base)
      base.extend Inheritance if base.is_a?(Class)
    end

    def page(page=nil)
      scoped.limit(pagination_limit).offset(pagination_offset(page.to_i))
    end

    def pagination_limit
      scoped.limit_value || self.per_page
    end

    def pagination_offset(page=1)
      [(pagination_limit * (page - 1)), 0].max
    end

    def pages
      (total_count.to_f / pagination_limit).ceil
    end

    def current_page
      [((scoped.offset_value || 0) / pagination_limit) + 1, pages].min
    end

    def first_page
      1
    end

    def last_page
      pages
    end

    def previous_page
      if current_page > 1
        current_page - 1
      else
        nil
      end
    end

    def next_page
      if current_page < pages
        current_page + 1
      else
        nil
      end
    end

    def total_count
      except(:limit, :offset, :order, :includes).count
    end

    def per_page
      defined?(@per_page) ? @per_page : 30
    end

    def per_page=(limit)
      @per_page = limit
    end

    # Get an array of nearby pages.
    def nearest_pages(number=5)
      first = current_page - (number / 2)
      first = 1 if first < 1
      last  = first + (number - 1)
      last  = pages if last > pages
      if (last - first) < number
        first = last - (number - 1)
        first = 1 if first < 1
      end
      (first..last).to_a
    end

  end

end