module Pagination

	class << self
		def paginate(options, &block)
			paginater = Pagination::Paginater.new(options)
			collection = yield(paginater)
			self.apply(collection, paginater)
		end
		
		def apply(collection, paginater)
			class << collection; include Pagination::InstanceMethods; end
			collection.paginater = paginater
			collection
		end
	end

	class Paginater
	    attr_reader :pages, :page, :total_count, :offset, :per_page
		alias :limit :per_page

		def initialize(options)
			@total_count = options[:total_count]
			@per_page    = options[:per_page]
			@page        = options[:page]
		end

		# Total number of pages
		def pages
			(total_count.to_f/per_page).ceil
		end
		
		def page
			if @page.to_s == "last"
				@page = pages
			else
				@page = @page.to_i
				@page = 1 if @page < 1
				@page = pages if @page > pages
			end
			@page
		end
		
		def offset
			o = per_page * (page - 1)
			o = 0 if o < 0
			o
		end
	end
	
	module InstanceMethods
		attr_accessor :paginater
		delegate :pages, :page, :total_count, :offset, :per_page, :to => :paginater

	    def previous_page
	        (page > 1) ? (page - 1) : nil
	    end

	    def next_page
	        (pages > page) ? (page + 1) : nil
	    end

	    def first_page; 1; end
	    def last_page; pages; end
    
	    def first_page?
	        (page == first_page) ? true : false
	    end

	    def last_page?
	        (page == last_page) ? true : false
	    end
    
	    def nearest_pages(number)
	        first = page - (number/2)
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