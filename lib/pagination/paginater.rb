module Pagination
	# The Paginater stores pagination info and handles the math. 
	# See the Pagination module documentation for usage examples.
	class Paginater

		# Total number of items
		attr_reader :total_count
		# Items per page
		attr_reader :per_page
		# Total number of pages
		attr_reader :pages
		# Number of items to present in context
		attr_reader :context
		# Current page
		attr_accessor :page

		# The following parameters are required:
		# * <tt>:total_count</tt> - Total count of items.
		# * <tt>:per_page</tt>    - Items per page.
		# * <tt>:page</tt>        - Current page.
		def initialize(options)
			@total_count = options[:total_count]
			@per_page    = options[:per_page]
			@page        = options[:page]
			@context     = options[:context] || 0
		end

		# Returns total number of pages.
		def pages
			(total_count.to_f/@per_page).ceil
		end
		
		# Returns the current page.
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
		
		def limit
			(context?) ? (@per_page + context) : @per_page
		end
		
		def context?
			(@context > 0 && page > 1) ? true : false
		end
		
		# Returns the start offset.
		def offset
			o = (per_page * (page - 1)) - context
			o = 0 if o < 0
			o
		end
	end
end