module Pagination

    attr_reader :pages, :page, :total_count, :offset, :per_page

	class << self
		# Applies pagination to the collection
		def apply(targets, options)
        	class << targets; include Pagination; end
			targets.setup_pagination(options)
			targets
		end
	end

    def setup_pagination(options={})
        @total_count = options[:total_count]
        @page        = options[:page]
        @per_page    = options[:per_page]

        @pages = (@total_count.to_f/@per_page).ceil
        @offset = (@page - 1) * @per_page
    end

    def previous_page
        (@page > 1) ? (@page - 1) : nil
    end

    def next_page
        (@pages > @page) ? (@page + 1) : nil
    end

    def first_page; 1; end
    def last_page; @pages; end
    
    def first_page?
        (@page == first_page) ? true : false
    end

    def last_page?
        (@page == last_page) ? true : false
    end
    
    def nearest_pages(number)
        first = @page - (number/2)
        first = 1 if first < 1
        last  = first + (number - 1)
        last  = @pages if last > @pages
        if (last - first) < number
            first = last - (number - 1)
            first = 1 if first < 1
        end
        (first..last).to_a
    end

end