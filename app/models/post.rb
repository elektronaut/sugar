# encoding: utf-8

class Post < ActiveRecord::Base
  include SearchablePost
  include Paginatable
  include Viewable

  self.per_page = 50

  belongs_to :user, :counter_cache => true
  belongs_to :exchange, counter_cache: :posts_count
  has_many   :discussion_views

  validates_presence_of :body, :user_id, :exchange_id
  validates :format, inclusion: %w{markdown html}

  attr_accessor :skip_html

  before_save :set_edit_timestamp
  before_save :update_trusted_status
  before_save :flag_conversation
  before_save :render_html
  after_create :update_exchange
  after_create :define_relationship
  after_create :notify_new_conversation_post
  after_create :increment_public_posts_count
  after_destroy :decrement_public_posts_count

  scope :sorted,                 -> { order('created_at ASC') }
  scope :for_view,               -> { sorted.includes(:user) }
  scope :for_view_with_exchange, -> { for_view.includes(:exchange) }

  def me_post?
    @me_post ||= (body.strip =~ /^\/me/ && !(body =~ /\n/) ) ? true : false
  end

  # Get this posts sequence number
  def post_number
    @post_number ||= self.exchange.posts.where('id < ?', self.id).count + 1
  end

  def page(options={})
    limit = options[:limit] || Post.per_page
    (post_number.to_f/limit).ceil
  end

  def body_html
    if self.new_record? || Rails.env == 'development'
      Sugar::PostRenderer.render(self.body, format: self.format)
    else
      unless body_html?
        self.update_column(:body_html, Sugar::PostRenderer.render(self.body, format: self.format))
      end
      self[:body_html].html_safe
    end
  end

  def edited?
    return false unless edited_at?
    (((self.edited_at || self.created_at) - self.created_at) > 60.seconds ) ? true : false
  end

  def editable_by?(user)
    (user && (user.moderator? || user == self.user)) ? true : false
  end

  def mentions_users?
    (mentioned_users.length > 0) ? true : false
  end

  def mentioned_users
    @mentioned_users ||= User.all.select do |user|
      user_expression = Regexp.new('@'+Regexp.quote(user.username), Regexp::IGNORECASE)
      self.body.match(user_expression) ? true : false
    end
  end

  private

  def increment_public_posts_count
    if !self.conversation? && !self.trusted?
      self.user.update_column(:public_posts_count, self.user.public_posts_count + 1)
    end
  end

  def decrement_public_posts_count
    if !self.conversation? && !self.trusted?
      self.user.update_column(:public_posts_count, self.user.public_posts_count - 1)
    end
  end

  def update_trusted_status
    if self.exchange
      self.trusted = self.exchange.trusted
    end
    true
  end

  def render_html
    unless self.skip_html
      self.body_html = Sugar::PostRenderer.render(self.body, format: self.format)
    end
  end

  def flag_conversation
    self.conversation = self.exchange.kind_of?(Conversation)
    true
  end

  def set_edit_timestamp
    self.edited_at ||= Time.now
  end

  # Make sure the exchange is marked as participated for the user
  def define_relationship
    unless self.conversation?
      DiscussionRelationship.define(self.user, self.exchange, :participated => true)
    end
  end

  # Automatically update the exchange with last poster info
  def update_exchange
    self.exchange.update_attributes(:last_poster_id => self.user.id, :last_post_at => self.created_at)
  end

  def notify_new_conversation_post
    if self.conversation?
      self.exchange.conversation_relationships.each do |relationship|
        relationship.update_attributes(new_posts: true) unless relationship.user == self.user
      end
    end
  end

end
