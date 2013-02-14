# encoding: utf-8

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
      relationship
    end
  end

  def update_user_caches!
    self.user.update_attributes({
      :participated_count => DiscussionRelationship.count(:all, :conditions => ['user_id = ? AND participated = ?', self.user.id, true]),
      :following_count    => DiscussionRelationship.count(:all, :conditions => ['user_id = ? AND following = ?', self.user.id, true]),
      :favorites_count    => DiscussionRelationship.count(:all, :conditions => ['user_id = ? AND favorite = ?', self.user.id, true])
    })
  end
end
