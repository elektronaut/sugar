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
		# Current page
		attr_reader :page

		alias :limit :per_page

		# The following parameters are required:
		# * <tt>:total_count</tt> - Total count of items.
		# * <tt>:per_page</tt>    - Items per page.
		# * <tt>:page</tt>        - Current page.
		def initialize(options)
			@total_count = options[:total_count]
			@per_page    = options[:per_page]
			@page        = options[:page]
		end

		# Returns total number of pages.
		def pages
			(total_count.to_f/per_page).ceil
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
		
		# Returns the start offset.
		def offset
			o = per_page * (page - 1)
			o = 0 if o < 0
			o
		end
	end
end