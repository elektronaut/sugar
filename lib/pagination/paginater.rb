module Pagination
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
		
		# Current page
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
		
		# Offset (number of rows from start)
		def offset
			o = per_page * (page - 1)
			o = 0 if o < 0
			o
		end
	end
end