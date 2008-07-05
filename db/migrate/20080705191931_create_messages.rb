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
    end

    def self.down
        drop_table :messages
    end
end
