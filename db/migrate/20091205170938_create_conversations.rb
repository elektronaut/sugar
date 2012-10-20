class CreateConversations < ActiveRecord::Migration
  def self.up
    add_column :discussions, :type, :string
    add_index  :discussions, :type
    Exchange.update_all({:type => 'Discussion'})

    add_column :posts, :conversation, :boolean, :null => false, :default => false
    add_index  :posts, :conversation

    create_table :conversation_relationships do |t|
      t.belongs_to :user, :conversation
      t.boolean    :notifications, :default => true, :null => false
      t.boolean    :new_posts,     :default => false, :null => false
      t.timestamps
    end
    add_index :conversation_relationships, :user_id
    add_index :conversation_relationships, :conversation_id
  end

  def self.down
    drop_table    :conversation_relationships
    remove_column :discussions, :type
    remove_column :posts, :conversation
  end
end
