class CacheDiscussionRelationshipCounts < ActiveRecord::Migration
	def self.up
		[:participated_count, :favorites_count, :following_count].each do |c|
			add_column :users, c, :integer, :null => false, :default => 0
		end
		execute "UPDATE users u SET 
			u.following_count    = (SELECT COUNT(*) FROM discussion_relationships r WHERE r.user_id = u.id AND following = 1),
			u.favorites_count    = (SELECT COUNT(*) FROM discussion_relationships r WHERE r.user_id = u.id AND favorite = 1),
			u.participated_count = (SELECT COUNT(*) FROM discussion_relationships r WHERE r.user_id = u.id AND participated = 1)"
	end

	def self.down
		[:participated_count, :favorites_count, :following_count].each do |c|
			remove_column :users, c
		end
	end
end
