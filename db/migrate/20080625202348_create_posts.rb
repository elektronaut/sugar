class CreatePosts < ActiveRecord::Migration
    def self.up
        create_table :posts do |t|
            t.text :body, :body_html
            t.belongs_to :user, :discussion
			t.boolean :trusted, :delta, :null => false, :default => false
            t.datetime :edited_at
            t.timestamps
        end
        add_index :posts, :user_id, :name => 'user_id_index'
        add_index :posts, :discussion_id, :name => 'discussion_id_index'
        add_index :posts, :created_at, :name => 'created_at_index'
        add_index :posts, :trusted, :name => 'trusted_index'
		add_index :posts, :delta, :name => 'delta_index'
		add_index :posts, [:user_id, :created_at]
		add_index :posts, [:discussion_id, :created_at]
    end

    def self.down
        drop_table :posts
    end
end
