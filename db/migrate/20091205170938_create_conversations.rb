class CreateConversations < ActiveRecord::Migration
	def self.up
		create_table :conversations do |t|
			t.string  :name
			t.integer :messages_count
			t.timestamps
		end
		create_table :conversation_relationships do |t|
			t.belongs_to :user
			t.belongs_to :conversation
			t.integer    :unread_count
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
