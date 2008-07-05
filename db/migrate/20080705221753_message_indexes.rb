class MessageIndexes < ActiveRecord::Migration
    def self.up
        add_index :messages, :recipient_id, :name => 'recipient_id_index'
        add_index :messages, :sender_id, :name => 'sender_id_index'
        add_index :messages, :read, :name => 'read_index'
        add_index :messages, :deleted, :name => 'deleted_index'
        add_index :messages, :deleted_by_sender, :name => 'deleted_by_sender_index'
    end

    def self.down
        add_index :messages, :name => 'recipient_id_index'
        add_index :messages, :name => 'sender_id_index'
        add_index :messages, :name => 'read_index'
        add_index :messages, :name => 'deleted_index'
        add_index :messages, :name => 'deleted_by_sender_index'
    end
end
