# encoding: utf-8

# = Exchange
#
# Exchange is the base class for all threads, which both Discussion and Conversation inherit from.

class Exchange < ActiveRecord::Base
  include HumanizableParam
  include Paginatable

  # Default number of discussions per page
  self.per_page = 30

  # Virtual attribute for the body of the first post
  attr_accessor :body, :format

  # Skips validation of @body if true
  attr_accessor :skip_body_validation

  # User which is updating the exchange, required for closing exchanges
  attr_accessor :updated_by

  belongs_to :poster,         class_name: 'User'
  belongs_to :closer,         class_name: 'User'
  belongs_to :last_poster,    class_name: 'User'
  has_many   :posts,          -> { order 'created_at ASC' }, dependent: :destroy, foreign_key: 'exchange_id'
  has_many   :exchange_views, dependent: :destroy, foreign_key: 'exchange_id'
  has_many   :users,          through: :posts

  scope :sorted,       -> { order('sticky DESC, last_post_at DESC') }
  scope :with_posters, -> { includes(:poster, :last_poster) }
  scope :for_view,     -> { sorted.with_posters }

  validates_presence_of :title
  validates_length_of   :title, maximum: 100
  validates_presence_of :body, on: :create, unless: :skip_body_validation

  validate :validate_closed

  after_create :create_first_post
  after_update :update_post_body

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

  def create_first_post
    if self.body && !self.body.empty?
      attributes = {
        user: self.poster,
        body: self.body
      }
      attributes[:format] = self.format unless self.format.blank?
      self.posts.create(attributes)
    end
  end

  def update_post_body
    if self.body && !self.body.empty? && self.body != self.posts.first.body
      attributes = {
        edited_at: Time.now,
        body: self.body
      }
      attributes[:format] = self.format unless self.format.blank?
      self.posts.first.update_attributes(attributes)
    end
  end

end
