# encoding: utf-8

module ConversationPost
  extend ActiveSupport::Concern

  included do
    before_save :flag_conversation
    after_create :notify_new_conversation_post
  end

  private

  def flag_conversation
    self.conversation = exchange.is_a?(Conversation)
    true
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
