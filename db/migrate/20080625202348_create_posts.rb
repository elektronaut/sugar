class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.text :body, :body_html
      t.belongs_to :user, :discussion
      t.boolean :trusted, :delta, :null => false, :default => false
      t.datetime :edited_at
      t.timestamps
    end
    add_index :posts, :user_id
    add_index :posts, :discussion_id
    add_index :posts, :created_at
    add_index :posts, :trusted
    add_index :posts, :delta
    add_index :posts, [:user_id, :created_at]
    add_index :posts, [:discussion_id, :created_at]
  end

  def self.down
    drop_table :posts
  end
end
