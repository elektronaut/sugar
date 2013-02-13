module Paginatable
  extend ActiveSupport::Concern

  module ClassMethods

    module Inheritance
      def inherited(subclass)
        super
        subclass.per_page = self.per_page
      end
    end

    module WithContext
      attr_accessor :context
      def context
        @context || 0
      end
    end

    def self.extended(base)
      base.extend Inheritance if base.is_a?(Class)
    end

    def page(page=nil, options={})
      scope = scoped.extend(WithContext)
      scope.context = page.to_i > 1 ? options[:context].to_i : 0
      scope
        .limit(pagination_limit + scope.context)
        .offset(pagination_offset(page.to_i) - scope.context)
    end

    def context
      scoped.context
    end

    def context?
      context != 0
    end

    def pages
      (total_count.to_f / (pagination_limit - context)).ceil
    end

    def current_page
      [(((scoped.offset_value || 0) + context) / (pagination_limit - context)) + 1, pages].min
    end

    def first_page
      1
    end

    def last_page
      pages
    end

    def first_page?
      current_page = first_page
    end

    def last_page?
      current_page == last_page
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
      count = except(:limit, :offset, :order, :includes).count
      count.is_a?(Hash) ? count.length : count
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

    private

    def pagination_limit
      if scoped.limit_value
        scoped.limit_value
      else
        self.per_page
      end
    end

    def pagination_offset(page=1)
      [(pagination_limit * (page - 1)), 0].max
    end

  end

end