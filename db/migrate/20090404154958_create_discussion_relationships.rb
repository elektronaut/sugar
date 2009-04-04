class CreateDiscussionRelationships < ActiveRecord::Migration
	def self.up
		create_table :discussion_relationships do |t|
			t.belongs_to :user, :discussion
			t.boolean :participated, :null => false, :default => false
			t.boolean :following,    :null => false, :default => true
			t.boolean :favorite,     :null => false, :default => false
			t.boolean :trusted,      :null => false, :default => false
		end
		add_index :discussion_relationships, :user_id,       :name => 'user_id_index'
		add_index :discussion_relationships, :discussion_id, :name => 'discussion_id_index'
		add_index :discussion_relationships, :participated,  :name => 'participated_index'
		add_index :discussion_relationships, :following,     :name => 'following_index'
		add_index :discussion_relationships, :favorite,      :name => 'favorite_index'
		add_index :discussion_relationships, :trusted,       :name => 'trusted_index'
	end

	def self.down
		drop_table :discussion_participations
	end
end
