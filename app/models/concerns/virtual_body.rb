module VirtualBody
  extend ActiveSupport::Concern

  included do
    attr_accessor :body, :format, :skip_body_validation
    after_create :create_first_post
    after_update :update_post_body
    validates :body, presence: true, on: :create, unless: :skip_body_validation
  end

  private

  def create_first_post
    if body && !body.empty?
      attributes = {
        user: poster,
        body: body
      }
      attributes[:format] = format unless format.blank?
      posts.create(attributes)
    end
  end

  def update_post_body
    if body && !body.empty? && body != posts.first.body
      attributes = {
        edited_at: Time.now,
        body: body
      }
      attributes[:format] = format unless format.blank?
      posts.first.update_attributes(attributes)
    end
  end
end
