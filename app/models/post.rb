# encoding: utf-8

class Post < ActiveRecord::Base
  include SearchablePost
  include Paginatable
  include Viewable

  self.per_page = 50

  belongs_to :user, counter_cache: true, touch: true
  belongs_to :exchange, counter_cache: :posts_count, touch: true
  has_many :exchange_views

  validates :body, :user_id, :exchange_id, presence: true
  validates :format, inclusion: %w(markdown html)

  attr_accessor :skip_html

  before_save :fetch_images,
              :set_edit_timestamp,
              :update_trusted_status,
              :flag_conversation,
              :render_html

  after_create :update_exchange,
               :define_relationship,
               :notify_new_conversation_post,
               :increment_public_posts_count

  after_destroy :decrement_public_posts_count

  scope :sorted,                 -> { order("created_at ASC") }
  scope :for_view,               -> { sorted.includes(user: [:avatar]) }
  scope :for_view_with_exchange, -> { for_view.includes(:exchange) }

  def me_post?
    @me_post ||= (body.strip =~ %r{^/me} && !(body =~ /\n/)) ? true : false
  end

  def post_number
    @post_number ||= exchange.posts.where("id < ?", id).count + 1
  end

  def page(options = {})
    limit = options[:limit] || Post.per_page
    (post_number.to_f / limit).ceil
  end

  def body_html
    if new_record? || Rails.env == "development"
      Renderer.render(body, format: format)
    else
      unless body_html?
        update_column(:body_html, Renderer.render(body, format: format))
      end
      self[:body_html].html_safe
    end
  end

  def edited?
    return false unless edited_at?
    (((edited_at || created_at) - created_at) > 60.seconds) ? true : false
  end

  def editable_by?(user)
    (user && (user.moderator? || user == self.user)) ? true : false
  end

  def fetch_images
    self.body = ImageFetcher.fetch(body)
  end

  def mentions_users?
    mentioned_users.any?
  end

  def mentioned_users
    @mentioned_users ||= User.all.select do |user|
      user_expression = Regexp.new(
        "@" + Regexp.quote(user.username),
        Regexp::IGNORECASE
      )
      body.match(user_expression) ? true : false
    end
  end

  private

  def update_public_posts_count(delta)
    return if conversation? || trusted?
    user.update_column(:public_posts_count, user.public_posts_count + delta)
  end

  def increment_public_posts_count
    update_public_posts_count(+1)
  end

  def decrement_public_posts_count
    update_public_posts_count(-1)
  end

  def update_trusted_status
    self.trusted = exchange.trusted if exchange
    true
  end

  def render_html
    self.body_html = Renderer.render(body, format: format) unless skip_html
  end

  def flag_conversation
    self.conversation = exchange.is_a?(Conversation)
    true
  end

  def set_edit_timestamp
    self.edited_at ||= Time.now.utc
  end

  def define_relationship
    return if conversation?
    DiscussionRelationship.define(user, exchange, participated: true)
  end

  def update_exchange
    exchange.update_attributes(
      last_poster_id: user.id,
      last_post_at: created_at
    )
  end

  def notify_new_conversation_post
    if conversation?
      exchange.conversation_relationships.each do |relationship|
        unless relationship.user == user
          relationship.update_attributes(new_posts: true)
        end
      end
    end
  end
end
