class CreateConversations < ActiveRecord::Migration
	def self.up
		create_table :conversations do |t|
			t.string     :name
			t.belongs_to :poster
			t.integer    :messages_count
			t.datetime   :last_message_at
			t.timestamps
		end
		create_table :conversation_relationships do |t|
			t.belongs_to :user, :conversation, :message
			t.integer    :message_index, :unread_count
			t.boolean    :notifications, :default => true, :null => false
			t.timestamps
		end
		add_column :messages, :conversation_id, :integer
	end

	def self.down
		drop_table    :conversations
	    drop_table    :conversation_relationships
		remove_column :messages, :conversation_id, :integer
	end
end
