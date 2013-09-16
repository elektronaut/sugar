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
      relationship = self.where(user_id: user.id, discussion_id: discussion.id).first
      relationship ||= DiscussionRelationship.create(:user_id => user.id, :discussion_id => discussion.id)
      relationship.update_attributes(options.merge({:trusted => discussion.trusted}))
      relationship.save
      relationship
    end
  end

  def update_user_caches!
    self.user.update_attributes({
      :participated_count => DiscussionRelationship.where(user_id: self.user.id, participated: true).count,
      :following_count    => DiscussionRelationship.where(user_id: self.user.id, following: true).count,
      :favorites_count    => DiscussionRelationship.where(user_id: self.user.id, favorite: true).count
    })
  end
end
