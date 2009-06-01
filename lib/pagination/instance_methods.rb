module Pagination

	# The InstanceMethods are mixed into the collection by 
	# Pagination.apply, which means they can be used in your views. 
	#
	# See the Pagination module documentation for more info and examples.

	module InstanceMethods
		# The paginater info object
		attr_accessor :paginater

		# Total number of pages.
		def pages
			paginater.pages
		end
		
		# Current page.
		def page
			paginater.page
		end
		
		# Total number of items.
		def total_count
			paginater.total_count
		end
		
		# Number of items per page.
		def per_page
			paginater.per_page
		end
		alias :limit :per_page
		
		# The start offset (number of items skipped).
		def offset
			paginater.offset
		end

		# Number of the first page (which for obious reasons is always 1).
		def first_page
			1
		end

		# Number of the last page.
		def last_page
			pages
		end

		# Number of the previous page, or nil if there isn't one.
		def previous_page
			(page > 1) ? (page - 1) : nil
		end

		# Number of the next page, or nil if there isn't one.
		def next_page
			(pages > page) ? (page + 1) : nil
		end

		# Returns true or false, depending if there's a previous page.
		def previous_page?
			(previous_page) ? true : false
		end

		# Returns true or false, depending if there's a next page.
		def next_page?
			(next_page) ? true : false
		end

		# Returns true if the collection is on the first page.
		def first_page?
			(page == first_page) ? true : false
		end

		# Returns true if the collection is on the last page.
		def last_page?
			(page == last_page) ? true : false
		end

		# Number of items presented in context
		def context
			paginater.context
		end

		# Returns true if the collection has items in context.
		def context?
			paginater.context?
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