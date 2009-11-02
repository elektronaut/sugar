class CreateMessages < ActiveRecord::Migration
    def self.up
        create_table :messages do |t|
            t.belongs_to :recipient, :sender
            t.string     :subject
            t.text       :body
            t.boolean    :read, :deleted, :deleted_by_sender, :null => false, :default => 0
            t.datetime   :replied_at
            t.timestamps
        end
        add_index :messages, :recipient_id, :name => 'recipient_id_index'
        add_index :messages, :sender_id, :name => 'sender_id_index'
        add_index :messages, :read, :name => 'read_index'
        add_index :messages, :deleted, :name => 'deleted_index'
        add_index :messages, :deleted_by_sender, :name => 'deleted_by_sender_index'
    end

    def self.down
        drop_table :messages
    end
end
