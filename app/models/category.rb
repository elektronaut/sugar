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
    
    after_save do |category|
        Discussion.update_all("trusted = " + (category.trusted? ? '1' : '0'), "category_id = #{category.id}")
    end
    
    class << self
        # Enable work safe URLs
        def work_safe_urls=(state)
            @@work_safe_urls = state
        end
		# Reports the state of the work_safe_urls flag.
        def work_safe_urls
            @@work_safe_urls ||= false
        end
    end

	# Returns true if this category is viewable by the given <tt>user</tt>.
    def viewable_by?(user)
        (user && !(self.trusted? && !(user.trusted? || user.admin?))) ? true : false
    end
    
    # Humanized ID for URLs.
    def to_param
        slug = self.name
        slug = slug.gsub(/[\[\{]/,'(')
        slug = slug.gsub(/[\]\}]/,')')
        slug = slug.gsub(/[^\w\d!$&'()*,;=\-]+/,'-').gsub(/[\-]{2,}/,'-').gsub(/(^\-|\-$)/,'')
        (Discussion.work_safe_urls) ? self.id : "#{self.id};" + slug
    end
    
	# Fixes any inconsistencies in the counter_cache columns.
	def fix_counter_cache!
		if discussions_count != discussions.count
			logger.warn "counter_cache error detected on Category ##{self.id} (discussions)"
			Category.update_counters(self.id, :discussions_count => (discussions.count - discussions_count) )
		end
	end
end
