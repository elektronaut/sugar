# encoding: utf-8

# = Exchange
#
# Exchange is the base class for all threads, which both Discussion and Conversation inherit from.

class Exchange < ActiveRecord::Base
  include HumanizableParam
  include Paginatable

  self.table_name = 'discussions'

  # Default number of discussions per page
  self.per_page = 30

  # These attributes should be filtered from params
  UNSAFE_ATTRIBUTES = :id, :sticky, :user_id, :last_poster_id, :posts_count,
                      :created_at, :updated_at, :last_post_at, :trusted

  # Virtual attribute for the body of the first post
  attr_accessor :body

  # Skips validation of @body if true
  attr_accessor :skip_body_validation

  # User which is updating the exchange, required for closing exchanges
  attr_accessor :updated_by

  belongs_to :poster,           class_name: 'User'
  belongs_to :closer,           class_name: 'User'
  belongs_to :last_poster,      class_name: 'User'
  has_many   :posts,            -> { order 'created_at ASC' }, dependent: :destroy, foreign_key: 'discussion_id'
  has_many   :discussion_views, :dependent => :destroy, :foreign_key => 'discussion_id'

  scope :sorted,       -> { order('sticky DESC, last_post_at DESC') }
  scope :with_posters, -> { includes(:poster, :last_poster) }
  scope :for_view,     -> { sorted.with_posters }

  validates_presence_of :title
  validates_length_of   :title, :maximum => 100
  validates_presence_of :body, :on => :create, :unless => :skip_body_validation

  validate :validate_closed

  after_create :create_first_post
  after_update :update_post_body

  class << self

    # Deletes attributes which normal users shouldn't be able to touch from a param hash
    def safe_attributes(params)
      safe_params = params.dup
      Exchange::UNSAFE_ATTRIBUTES.each do |r|
        safe_params.delete(r)
      end
      return safe_params
    end

  end

  # Finds the number of the last page
  def last_page(per_page=Post.per_page)
    (self.posts_count.to_f / per_page).ceil
  end

  # Does this exchange have any labels?
  def labels?
    (self.closed? || self.sticky? || self.nsfw? || self.trusted?) ? true : false
  end

  # Returns an array of labels (for use in the thread title)
  def labels
    labels = []
    labels << "Trusted" if self.trusted?
    labels << "Sticky"  if self.sticky?
    labels << "Closed"  if self.closed?
    labels << "NSFW"    if self.nsfw?
    return labels
  end

  # Humanized ID for URLs
  def to_param
    self.humanized_param(self.title)
  end

  # Returns true if the user can close this discussion
  def closeable_by?(user)
    return false unless user
    (user.moderator? || (!self.closer && self.poster == user) || self.closer == user) ? true : false
  end

  private

  # Validate and handle closing of discussions
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

  # Automatically create the first post
  def create_first_post
    if self.body && !self.body.empty?
      self.posts.create(:user => self.poster, :body => self.body)
    end
  end

  # Update the first post if @body has been changed
  def update_post_body
    if self.body && !self.body.empty? && self.body != self.posts.first.body
      self.posts.first.update_attributes(:body => self.body, :edited_at => Time.now)
    end
  end

end
