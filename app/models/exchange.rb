# encoding: utf-8

# = Exchange
#
# Exchange is the base class for all threads, which both Discussion and Conversation inherit from.

class Exchange < ActiveRecord::Base
  include HumanizableParam
  include Paginatable
  include ExchangeScopes
  include VirtualBody

  self.per_page = 30

  attr_accessor :updated_by

  belongs_to :poster, class_name: 'User'
  belongs_to :last_poster, class_name: 'User'

  belongs_to :closer,         class_name: 'User'
  has_many   :posts,          -> { order 'created_at ASC' }, dependent: :destroy, foreign_key: 'exchange_id'
  has_many   :exchange_views, dependent: :destroy, foreign_key: 'exchange_id'
  has_many   :users,          through: :posts

  validates :title, presence: true, length: { maximum: 100 }
  validate :validate_closed

  def last_page(per_page=Post.per_page)
    (self.posts_count.to_f / per_page).ceil
  end

  def labels?
    (self.closed? || self.sticky? || self.nsfw? || self.trusted?) ? true : false
  end

  def labels
    labels = []
    labels << "Trusted" if self.trusted?
    labels << "Sticky"  if self.sticky?
    labels << "Closed"  if self.closed?
    labels << "NSFW"    if self.nsfw?
    return labels
  end

  def to_param
    self.humanized_param(self.title)
  end

  def closeable_by?(user)
    return false unless user
    (user.moderator? || (!self.closer && self.poster == user) || self.closer == user) ? true : false
  end

  private

  def validate_closed
    if self.closed_changed?
      if !self.closed? && (!self.updated_by || !self.closeable_by?(self.updated_by))
        self.errors.add(:closed, "can't be changed!")
      elsif self.closed?
        self.closer = self.updated_by
      else
        self.closer = nil
      end
    end
  end
end
