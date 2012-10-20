class CacheDiscussionRelationshipCounts < ActiveRecord::Migration
  def self.up
    [:participated_count, :favorites_count, :following_count].each do |c|
      add_column :users, c, :integer, :null => false, :default => 0
    end
    execute "UPDATE users SET
      following_count    = (SELECT COUNT(*) FROM discussion_relationships WHERE discussion_relationships.user_id = users.id AND following = 1),
      favorites_count    = (SELECT COUNT(*) FROM discussion_relationships WHERE discussion_relationships.user_id = users.id AND favorite = 1),
      participated_count = (SELECT COUNT(*) FROM discussion_relationships WHERE discussion_relationships.user_id = users.id AND participated = 1)"
  end

  def self.down
    [:participated_count, :favorites_count, :following_count].each do |c|
      remove_column :users, c
    end
  end
end
