class OptimizeIndexes < ActiveRecord::Migration
	def self.up
		add_index :discussions, [:sticky, :last_post_at]
		add_index :posts, [:user_id, :created_at]
		add_index :posts, [:discussion_id, :created_at]
	end

	def self.down
		remove_index :discussions, :column => [:sticky, :last_post_at]
		remove_index :posts, :column => [:user_id, :created_at]
		remove_index :posts, :column => [:discussion_id, :created_at]
	end
end
