class DiscussionRelationship < ActiveRecord::Base
	belongs_to :user
	belongs_to :discussion
	
	after_save do |relationship|
		relationship.update_user_caches!
	end
	
	after_destroy do |relationship|
		relationship.update_user_caches!
	end

	class << self
		# Define a relationship with a discussion
		def define(user, discussion, options={})
			relationship = self.find(:first, :conditions => ['user_id = ? AND discussion_id = ?', user.id, discussion.id])
			relationship ||= DiscussionRelationship.create(:user_id => user.id, :discussion_id => discussion.id)
			relationship.update_attributes(options.merge({:trusted => discussion.trusted}))
			relationship.save
		end
		
		# Find participated discussions for a user
		def find_participated(user, options={})
			self.find_discussions(user, {:participated => true}.merge(options))
		end
		
		# Find followed discussions for a user
		def find_following(user, options={})
			self.find_discussions(user, {:following => true}.merge(options))
		end

		# Find favorite discussions for a user
		def find_favorite(user, options={})
			self.find_discussions(user, {:favorite => true}.merge(options))
		end
		
		def find_discussions(user, options={})
			paginate = options.has_key?(:page)
			
			find_conditions = [:participated, :following, :favorite].inject(Hash.new) do |cond, key|
				cond[key] = ((options[key]) ? '1' : '0') if options.has_key?(key)
				cond
			end.merge({:user_id => user.id})
			
			find_conditions[:trusted] = false unless options[:trusted]
			find_options = {}

			if paginate
	            limit     = options[:limit] || Discussion::DISCUSSIONS_PER_PAGE
				discussions_count = self.count(:all, :conditions => find_conditions)
	            num_pages = (discussions_count.to_f/limit).ceil
	            page      = (options[:page] || 1).to_i
	            page      = 1 if page < 1
	            page      = num_pages if page > num_pages
	            offset    = limit * (page - 1)
				offset    = 0 if offset < 0
	
				find_options = {
					:limit => limit,
					:offset => offset
				}.merge(find_options)
			end
			
			join_string = "INNER JOIN `discussion_relationships` ON `discussion_relationships`.discussion_id = `discussions`.id"
			join_string += " AND " + find_conditions.map{|k,v| "`discussion_relationships`.#{k.to_s} = #{v}"}.join(" AND ")
			
			find_options = {
				:select     => '`discussions`.*',
				#:conditions => find_conditions,
				:joins      => join_string,
                :order      => '`discussions`.sticky DESC, `discussions`.last_post_at DESC',
                :include    => [:poster, :last_poster, :category]
			}.merge(find_options)

			discussions = Discussion.find(:all, find_options)
			if paginate
				Pagination.apply(discussions, Pagination::Paginater.new(:total_count => discussions_count, :page => page, :per_page => limit))
			end
			discussions
		end
	end
	
	def update_user_caches!
		self.user.update_attributes({
			:participated_count => DiscussionRelationship.count(:all, :conditions => ['user_id = ? AND participated = 1', self.user.id]),
			:following_count    => DiscussionRelationship.count(:all, :conditions => ['user_id = ? AND following = 1', self.user.id]),
			:favorites_count    => DiscussionRelationship.count(:all, :conditions => ['user_id = ? AND favorite = 1', self.user.id])
		})
	end
end
