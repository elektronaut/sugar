require File.join(File.dirname(__FILE__), 'pagination/paginater')
require File.join(File.dirname(__FILE__), 'pagination/instance_methods')

module Pagination
	class << self
		# Applies pagination to the result set from the block passed. 
		#
		# Example:
		#
		#   Pagination.paginate(
		#   	:total_count => Post.count(:all),
		#   	:per_page    => Post::POSTS_PER_PAGE,
		#   	:page        => options[:page] || 1
		#   ) do |pagination|
		#   	Post.find(
		#   		:all,
		#   		:limit   => pagination.limit,
		#   		:offset  => pagination.offset,
		#   		:order   => 'created_at ASC',
		#   	)
		#   end
		def paginate(options, &block)
			paginater = Pagination::Paginater.new(options)
			collection = yield(paginater)
			self.apply(collection, paginater)
		end
		
		# Apply the paginater to a collection
		def apply(collection, paginater)
			class << collection; include Pagination::InstanceMethods; end
			collection.paginater = paginater
			collection
		end
	end
end