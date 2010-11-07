# = Category model
#
# All discussions must belong to a category. There's not much functionality
# attached to categories, except that discussions can be browsed by category,
# and categories can be set as only visible to trusted users.
#
# === Trusted categories
# Categories can be flagged as <tt>trusted</tt>, only admins and users set 
# as trusted can view discussions in these. Use <tt>viewable_by?</tt> to 
# determine if a category is visible to a user. 

class Category < ActiveRecord::Base

	has_many :discussions
	validates_presence_of :name
	acts_as_list

	# Flag for trusted status, which will update after save if it has been changed.
	attr_accessor :update_trusted

	before_update do |category|
		category.update_trusted = true if category.trusted_changed?
	end

	after_save do |category|
		if category.update_trusted
			Discussion.update_all("trusted = " + (category.trusted? ? '1' : '0'), "category_id = #{category.id}")
		end
	end

	class << self
		
		# Finds all categories viewable by the given user
		def find_viewable_by(user=nil)
			self.all(:order => :position).select{|c| c.viewable_by?(user)}
		end
		
		# Enable work safe URLs
		def work_safe_urls=(state)
			@@work_safe_urls = state
		end
		# Reports the state of the work_safe_urls flag.
		def work_safe_urls
			@@work_safe_urls ||= false
		end
	end

	# Returns true if this category has any labels
	def labels?
		(self.trusted?) ? true : false
	end

	# Returns an array of labels (for use in the thread title)
	def labels
		labels = []
		labels << "Trusted" if self.trusted?
		return labels
	end

	# Returns true if this category is viewable by the given <tt>user</tt>.
	def viewable_by?(user)
		if self.trusted?
			(user && (user.trusted? || user.admin?)) ? true : false
		else
			(Sugar.config(:public_browsing) || user) ? true : false
		end
	end

	# Humanized ID for URLs.
	def to_param
		slug = self.name
		slug = slug.gsub(/[\[\{]/,'(')
		slug = slug.gsub(/[\]\}]/,')')
		slug = slug.gsub(/[^\w\d!$&'()*,;=\-]+/,'-').gsub(/[\-]{2,}/,'-').gsub(/(^\-|\-$)/,'')
		(Category.work_safe_urls) ? self.id.to_s : "#{self.id.to_s};" + slug
	end

	# Fixes any inconsistencies in the counter_cache columns.
	def fix_counter_cache!
		if discussions_count != discussions.count
			logger.warn "counter_cache error detected on Category ##{self.id} (discussions)"
			Category.update_counters(self.id, :discussions_count => (discussions.count - discussions_count) )
		end
	end
	
	if ENV['RAILS_ENV'] == 'test'
		def discussions_count
			self.discussions.count
		end 
	end
	
end
