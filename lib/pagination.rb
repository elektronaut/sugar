require File.join(File.dirname(__FILE__), 'pagination/paginater')
require File.join(File.dirname(__FILE__), 'pagination/instance_methods')

# = Pagination
#
# The Pagination module provides simple pagination for any set of records.
#
# === Example
#
#   class Discussion
#     has_many :posts
# 
#     # Finds paginated posts
#     def paginated_posts(options={})
#       Pagination.paginate(
#         :total_count => Post.count(:all, :conditions => ['discussion_id = ?', this.id]),
#         :per_page    => options[:per_page] || 50,
#         :page        => options[:page]     || 1
#       ) do |pagination|
#         Post.find(
#           :all,
#           :conditions => ['discussion_id = ?', this.id]
#           :limit      => pagination.limit,
#           :offset     => pagination.offset,
#           :order      => 'created_at ASC',
#         )
#       end
#     end
#   end
#
# You can now load paginated posts by doing: 
#   @posts = @discussion.paginated_posts(:page => params[:page])
#
# The posts array will have Pagination::InstanceMethods mixed in, which 
# means you can do:
#
#   @posts.total_count      # => 156
#   @posts.pages            # => 4
#   @posts.page             # => 1
#   @posts.next_page        # => 2
#   @posts.previous_page?   # => false
#   @posts.nearest_pages(3) # => [1,2,3]
#
# === Wrapping incompatible pagination
#
# Some plugins (ie. thinking-sphinx) provide their own pagination. 
# You can create a Paginater object and manually apply this to the collection
# in order to reuse your pagination view code:
#
#   posts = Post.search('music', :per_page => 20, :page => 1)
#   paginater = Pagination::Paginater.new(:total_count => posts.total_entries, :page => 1, :per_page => 20)
#   Pagination.apply(posts, paginater)


module Pagination
	class << self
		# Applies pagination to the result set returned from the given block.
		# See the <tt>Pagination</tt> module for usage examples.
		def paginate(options, &block)
			paginater = Pagination::Paginater.new(options)
			collection = yield(paginater)
			self.apply(collection, paginater)
		end
		
		# Applies a paginater to a collection.
		def apply(collection, paginater)
			class << collection; include Pagination::InstanceMethods; end
			collection.paginater = paginater
			collection
		end
	end
end