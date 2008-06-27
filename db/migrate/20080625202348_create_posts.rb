class CreatePosts < ActiveRecord::Migration
    def self.up
        create_table :posts do |t|
            t.text :body
            t.belongs_to :user, :discussion
            t.timestamps
        end
        add_index :posts, :user_id, :name => 'user_id_index'
        add_index :posts, :discussion_id, :name => 'discussion_id_index'
        add_index :posts, :created_at, :name => 'created_at_index'
    end

    def self.down
        drop_table :posts
    end
end
