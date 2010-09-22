class ConvertMessages < ActiveRecord::Migration
	def self.up
		ThinkingSphinx.deltas_enabled = false
		
		partners = Message.find_by_sql("SELECT DISTINCT sender_id, recipient_id FROM messages")
		partners = partners.map{|m| [m.sender_id, m.recipient_id].sort}.uniq
		partners = partners.map{|p| p.map{|i| User.find(i)}}
		
		partners.each do |user1, user2|
			puts "#{user1.username} -> #{user2.username}"
			messages = Message.find(
				:all, 
				:conditions => ['(sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?)', user1.id, user2.id, user2.id, user1.id],
				:order      => 'created_at ASC',
				:include    => [:sender, :recipient]
			)

			threaded_messages = {}
			subject           = "Conversation between "+[user1.username, user2.username].sort.join(' and ')
			messages.each do |message|
				subject = message.subject if message.subject?
				subject = subject[0...100]
				if message.body?
					threaded_messages[subject] ||= []
					threaded_messages[subject] << message
				end
			end
			threaded_messages.each do |title, messages|
				conversation = Conversation.create({:skip_body_validation => true, :title => title, :poster => messages.first.sender, :created_at => messages.first.created_at})
				last_read = {}
				messages.each do |message|
					#begin
						post = conversation.posts.create(:user => message.sender, :body => message.body, :created_at => message.created_at, :updated_at => message.updated_at, :skip_html => true)
						last_read[message.sender] = post
						if message.read?
							last_read[message.recipient] = post
						end
					#rescue
					#	raise message.inspect
					#end
				end
				# Create relationships
				[user1, user2].each do |user|
					ConversationRelationship.create(
						:conversation => conversation,
						:user         => user,
						:new_posts    => ((messages.select{|m| m.recipient_id == user.id && !m.read?}.length > 0) ? true : false)
					)
				end
				# Mark as viewed
				last_read.each do |user, last_post|
					user.mark_discussion_viewed(conversation, last_post, (conversation.posts.index(last_post) + 1))
				end
			end
		end

		drop_table :messages
	end

	def self.down
		#Conversation.destroy_all
		#ConversationRelationship.destroy_all
	end
end

class Message < ActiveRecord::Base
    belongs_to :recipient, :class_name => 'User'
    belongs_to :sender, :class_name => 'User'
end