# encoding: utf-8

class DiscussionRelationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :discussion

  before_validation :ensure_unfollow_unfavorite_and_hidden_are_mutually_exclusive

  after_save do |relationship|
    relationship.update_user_caches!
  end

  after_destroy do |relationship|
    relationship.update_user_caches!
  end

  class << self
    def define(user, discussion, options = {})
      relationship = where(user_id: user.id, discussion_id: discussion.id).first
      relationship ||= DiscussionRelationship.create(user_id: user.id, discussion_id: discussion.id)
      relationship.update_attributes(options.merge(trusted: discussion.trusted))
      relationship.save
      relationship
    end
  end

  def update_user_caches!
    user.update_attributes(
      participated_count: DiscussionRelationship.where(user_id: user.id, participated: true).count,
      following_count:    DiscussionRelationship.where(user_id: user.id, following: true).count,
      favorites_count:    DiscussionRelationship.where(user_id: user.id, favorite: true).count,
      hidden_count:       DiscussionRelationship.where(user_id: user.id, hidden: true).count
    )
  end

  protected

  def ensure_unfollow_unfavorite_and_hidden_are_mutually_exclusive
    if self.hidden?
      if self.hidden_changed?
        # Unfollow if discussion has been hidden
        self.following = false
        self.favorite = false
      elsif (self.favorite_changed? && self.favorite?) || (self.following_changed? && self.following?)
        # Unhide if discussion has been followed/favorited
        self.hidden = false
      end
    end
    true
  end
end
