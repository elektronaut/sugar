module Pagination
	module InstanceMethods
		attr_accessor :paginater
		delegate :pages, :page, :total_count, :offset, :per_page, :to => :paginater

		# Previous page number
		def previous_page
			(page > 1) ? (page - 1) : nil
		end

		# Next page number
		def next_page
			(pages > page) ? (page + 1) : nil
		end

		# Is there a previous page?
		def previous_page?
			(previous_page) ? true : false
		end

		# Is there a next page?
		def next_page?
			(next_page) ? true : false
		end

		# First page number
		def first_page
			1
		end

		# Last page number
		def last_page
			pages
		end

		# Is the collection on the first page?
		def first_page?
			(page == first_page) ? true : false
		end

		# Is the collection on the last page?
		def last_page?
			(page == last_page) ? true : false
		end

		# Get an array of nearby pages. 
		def nearest_pages(number=5)
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