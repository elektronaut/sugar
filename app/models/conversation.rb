class Conversation < ActiveRecord::Base
	has_many :messages, :dependent => :destroy
	has_many :conversation_relationships, :dependent => :destroy
	has_many :participants, :through => :conversation_relationships, :source => :user
end
