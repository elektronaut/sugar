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