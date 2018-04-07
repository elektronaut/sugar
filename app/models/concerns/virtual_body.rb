module VirtualBody
  extend ActiveSupport::Concern

  included do
    attr_accessor :body, :format
    after_create :create_first_post
    after_update :update_post_body
    validates :body, presence: true, on: :create
  end

  private

  def create_first_post
    return if body.blank?
    attributes = {
      user: poster,
      body: body
    }
    attributes[:format] = format unless format.blank?
    posts.create(attributes)
  end

  def format_options
    return {} if format.blank?
    { format: format }
  end

  def post_attributes
    {
      edited_at: Time.now.utc,
      body: body
    }.merge(format_options)
  end

  def update_post_body
    if body && !body.empty? && body != posts.first.body
      posts.first.update_attributes(post_attributes)
    end
  end
end
