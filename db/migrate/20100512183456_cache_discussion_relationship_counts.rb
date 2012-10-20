class CacheDiscussionRelationshipCounts < ActiveRecord::Migration
  def self.up
    [:participated_count, :favorites_count, :following_count].each do |c|
      add_column :users, c, :integer, :null => false, :default => 0
    end
    User.update_all(
      ["following_count = (SELECT COUNT(*) FROM discussion_relationships WHERE discussion_relationships.user_id = users.id AND following = ?)", true]
    )
    User.update_all(
      ["favorites_count = (SELECT COUNT(*) FROM discussion_relationships WHERE discussion_relationships.user_id = users.id AND favorite = ?)", true]
    )
    User.update_all(
      ["participated_count = (SELECT COUNT(*) FROM discussion_relationships WHERE discussion_relationships.user_id = users.id AND participated = ?)", true]
    )
  end

  def self.down
    [:participated_count, :favorites_count, :following_count].each do |c|
      remove_column :users, c
    end
  end
end
